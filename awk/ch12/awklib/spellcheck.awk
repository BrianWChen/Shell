BEGIN {
	if (ARGC > 1){
		if (ARGC > 2){
			if (ARGV[1]~/^\+.*/)
				SPELLDICT = ARGV[1]
			else
				SPELLDICT = "+" ARGV[1]
			SPELLFILE = ARGV[2]
			delete ARGV[1]
			delete ARGV[2]
		}
		else{
			SPELLFILE = ARGV[1]
			if(!system("test -r dict")){
				printf("Use local dict file? (y/n)")
				getline replay < "-"
				if(reply~/[yY](es)?/){
					SPELLDICT = "+dict"
				}
			}
		}
	}
	else {
		print "Usage: spellcheck [+dict] file"
		exit 1
	}

	wordlist = "sp_wordlist"
	spellsource = "sp_input"
	spellout = "sp_out"
	system("cp " SPELLFILE " " spellsource)

	print "Running spell checker ..."
	if (SPELLDICT)
		SPELLCMD = "spell " SPELLDICT " "
	else
		SPELLCMD = "spell "
	system(SPELLCMD spellsource " > " wordlist)

	if (system("test -s " wordlist)){
		print "No misspelled words found."
		system("rm " spellsource " " wordlist) 
		exit
	}
	ARGV[1] = wordlist

	responseList = "Responses: \n \tChange each occurrencd,"
	responseList = responseList "\n \tGlobal change,"
	responseList = responseList "\n \tAdd to Dict,"
	responseList = responseList "\n \tHelp,"
	responseList = responseList "\n \tQuit,"
	responseList = responseList "\n \tCR to ignore,"
	printf("%s", responseList)		
}
#main
{
	misspelling = $1
	response = 1
	++word
	
	while (response!~/(^[cCgGaAhHqQ])|^&/){
		printf("\n%d -Found %s (C/G/A/H/Q):", word, misspelling)
		getline response < "-"
	}

	if (response~/[Hh](elp)?/){
		printf("%s", responseList)
		printf("\n%d -Found %s (C/G/A/Q):", word, misspelling)
		getline response < "-"
	}

	if (response~/[Qq](uit)?/) exit
	
	if (response~/[Aa](dd)?/){
		dict[++dictEntry] = misspelling
	}
	
	if (response~/[Cc](hange)?/){
		newspelling = ""
		changes = ""
		while ((getline < spellsource) > 0){
			make_change($0)
			print > spellout
		}
		close(spellout)
		close(spellsource)
		
		if (changes){
			for (j = 1; j <= changes; ++j)
				print changedLines[j]	
			printf("%d lines changed.", changes)
			confirm_changes()
		}
	}
	if (response~/[Gg](lobal)?/){
		make_global_change()
	}
}

END{
	if (NR <=1) exit
	while (saveAnswer!~/([Yy](es)?)|([Nn]o?)/){
		printf("Save corrections in %s (y/n)? ", SPELLFILE)
		getline saveAnswer < "-"
	}
	if (saveAnswer~/^[Yy ]/){
		system("cp " SPELLFILE " " SPELLFILE ".orig")
		system("mv " spellsource " " SPELLFILE)
	}
	if (saveAnswer~/^[Nn]/)
		system("rm " spellsource)
	if (dictEntry){
		printf("Make changes to dictionary (y/n)? ")
		getline response < "-"
		if (response~/^[Yy]/){
			if (!SPELLDICT) SPELLDICT = "dict"
			sub(/^\+/,"",SPELLDICT)
			for (item in dict)
				print dict[item] >> SPELLDICT
			close(SPELLDICT)
			system("sort " SPELLDICT " > tmp_dict")
			system("mv tmp_dict " SPELLDICT)
		}
	}
	system("rm sp_wordlist")
}

function make_change(stringToChange, len,
	line, OKmakechange, printstring, carets)
{
	if (match(stringToChange, misspelling)){
		printstring = $0
		gsub(/\t/, "", printstring)
		print printstring
		carets = "^"
		for (i = 1; i < RLENGTH; ++i)
			carets = carets "^"
		if (len)
			FMT = "%" len + RSTART + RLENGTH - 2 "s\n"
		else
			FMT = "%" RSTART + RLENGTH - 1 "s\n"
		printf(FMT, carets)
	
		if(!newspelling){
			printf "Change to: "
			getline newspelling < "-"
		}

		while (newspelling && !OKmakechange){
			printf("Change %s to %s? (y/n):", misspelling, newspelling)
			getline OKmakechange < "-"
			madechg = ""
			if (OKmakechange~/[Yy](es)?/){
				madechg = sub(misspelling, newspelling, stringToChange)
			}
			else if ( OKmakechange~/[Nn]o?/){
				printf "Change to:"
				getline newspelling < "-"
				OKmakechange = ""
			}
		}

		if (len){
			line = substr($0, 1, len-1)
			$0 = line stringToChange
		}
		else{
			$0 = stringToChange
			if (madechg) ++changes
		}

		if (madechg)
			changedLines[changes] = ">" $0
		
		len += RSTART + RLENGTH
		part1 = substr($0, 1, len-1)
		part2 = substr($0, len)
		make_change(part2, len)
	}
}

function make_global_change(  newspelling, OKmakechange, changes)
{
	printf "Globally change to:"
	getline newspelling < "-"

	while (newspelling && !OKmakechange){
		printf("Globally change %s to %s? (y/n):", misspelling, newspelling)
		getline OKmakechange < "-"
		if (OKmakechange~/[Yy](es)?/){
			while ((getline < spellsource) > 0){
				if ($0~misspelling){
					madechg = gsub(misspelling, newspelling)
					print ">", $0
					changes += 1
				}
				print > spellout
			}
			close(spellout)
			close(spellsource)
			printf("%d lines changed.", changes)
			confirm_changes()
		}
		else if (OKmakechange~/[Nn]o?/){
			printf "Globally change to: "
			getline newspelling < "-"
			OKmakechange = ""
		}
	}
}

function confirm_changes(  savechanges){
	while (!savechanges){
		printf("Save changes?(y/n) ")
		getline savechanges < "-"
	}
	
	if (savechanges~/[Yy](es)?/)
		system("mv " spellout " " spellsource)
}
