SPADE=0x30
HEART=0x20
DIAMOND=0x10
CLOVER=0x0

ACE=0xe
KING=0xd
QUEEN=0xc
JACK=0xb

Hand={}
for i=1,7 do
	Card=io.read("*n")
	table.insert(Hand,Card)
end

CardTable={1,2,3,4,5}

MaxCombination=0x0

STRAIGHT_FLUSH=0x9
FOUR_CARD=0x8
FULL_HOUSE=0x7
FLUSH=0x6
STRAIGHT=0x5
THREE_CARD=0x4
TWO_PAIR=0x3
ONE_PAIR=0x2
HIGH_CARD=0x1

function Compare(a,b)
	if a&0xf ~= b&0xf then
		return a&0xf > b&0xf
	elseif a>>4 ~= b>>4 then
		return a>>4 > b>>4
	else
		return a > b
	end
end

function Combination()
	local combo=0x0
	local check=0x0
	table.sort(SelectFive,Compare)
	print(string.format("%02X",SelectFive[1])
		..","..string.format("%02X",SelectFive[2])
		..","..string.format("%02X",SelectFive[3])
		..","..string.format("%02X",SelectFive[4])
		..","..string.format("%02X",SelectFive[5]))
	local complete=true
	for i=2,5 do
		if (SelectFive[1]>>4)==(SelectFive[i]>>4)
			and ((SelectFive[1]&0xf)==(SelectFive[i]&0xf)+(i-1)) then
		else
			complete=false
			break
		end
	end
	if complete then
		check=(STRAIGHT_FLUSH<<28)
		for i=1,5 do
			check=check|((SelectFive[i]&0xf)<<(4*(5-i)))
		end
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	complete=true
	for i=2,5 do
		if (SelectFive[2]>>4)==(SelectFive[i]>>4)
			and SelectFive[i]&0xf==7-i then
		else
			complete=false
			break
		end
	end
	if (SelectFive[2]>>4)==(SelectFive[1]>>4) and SelectFive[1]&0xf==ACE then
	else
		complete=false
	end
	if complete then
		check=(STRAIGHT_FLUSH<<28)
		for i=2,5 do
			check=check|((SelectFive[i]&0xf)<<(4*(6-i)))
		end
		check=check|(SelectFive[1]&0xf)
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	local kinds={}
	for i=2,14 do
		kinds[i]=0
	end
	for i=1,5 do
		kinds[SelectFive[i]&0xf]=kinds[SelectFive[i]&0xf]+1
	end
	local four_card=nil
	local highs={}
	for i=2,14 do
		if kinds[i]==4 then
			four_card=i
		end
		if kinds[i]==1 then
			table.insert(highs,i)
		end
	end
	table.sort(highs,Compare)
	if four_card then
		check=(FOUR_CARD<<28)|((four_card*0x1111)<<4)|highs[1]
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	local three_card=nil
	local first_pair=nil
	local second_pair=nil
	for i=2,14 do
		if kinds[i]==3 then
			three_card=i
		end
		if kinds[i]==2 then
			if first_pair then
				second_pair=i
			else
				first_pair=i
			end
		end
	end
	if three_card and first_pair then
		check=(FULL_HOUSE<<28)|((three_card*0x111)<<8)|(first_pair*0x11)
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	complete=true
	for i=2,5 do
		if (SelectFive[1]>>4)==(SelectFive[i]>>4) then
		else
			complete=false
			break
		end
	end
	if complete then
		check=(FLUSH<<28)
		for i=1,5 do
			check=check|((SelectFive[i]&0xf)<<(4*(5-i)))
		end
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	complete=true
	for i=2,5 do
		if (SelectFive[1]&0xf)==(SelectFive[i]&0xf)+(i-1) then
		else
			complete=false
			break
		end
	end
	if complete then
		check=(STRAIGHT<<28)
		for i=1,5 do
			check=check|((SelectFive[i]&0xf)<<(4*(5-i)))
		end
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	complete=true
	for i=2,5 do
		if SelectFive[i]&0xf==7-i then
		else
			complete=false
			break
		end
	end
	if SelectFive[1]&0xf==ACE then
	else
		complete=false
	end
	if complete then
		check=(STRAIGHT<<28)
		for i=2,5 do
			check=check|((SelectFive[i]&0xf)<<(4*(6-i)))
		end
		check=check|(SelectFive[1]&0xf)
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	if three_card then
		check=(THREE_CARD<<28)|((three_card*0x111)<<8)|(highs[1]<<4)|(highs[2])
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	if first_pair and second_pair then
		if first_pair<second_pair then
			first_pair,second_pair=second_pair,first_pair
		end
		check=(TWO_PAIR<<28)|((first_pair*0x11)<<12)|((second_pair*0x11)<<4)|(highs[1])
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	if first_pair and not second_pair then
		check=(ONE_PAIR<<28)|((first_pair*0x11)<<12)|(highs[1]<<8)|(highs[2]<<4)|highs[3]
		combo=math.max(combo,check)
		MaxCombination=math.max(MaxCombination,combo)
		return
	end
	check=(HIGH_CARD<<28)
	for i=1,5 do
		check=check|((highs[i])<<(4*(5-i)))
	end
	combo=math.max(combo,check)
	MaxCombination=math.max(MaxCombination,combo)
end

while true do
	SelectFive={}
	for i=1,5 do
		table.insert(SelectFive,Hand[CardTable[i]])
	end
	Combination()
	local i=5
	while i>0 do
		if i>1 and CardTable[i]>=7-(5-i) then
			for j=i,5 do
				CardTable[j]=CardTable[i-1]+j-(i-2)
			end
			i=i-1
		else
			CardTable[i]=CardTable[i]+1
			break
		end
	end
	if CardTable[1]==4 then
		break
	end
end

print(string.format("%08X",MaxCombination))