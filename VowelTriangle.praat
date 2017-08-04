#! praat
# 
# Plot vowels into a vowel triangle
#
# Unless specified otherwise:
#
# Copyright: R.J.J.H. van Son, 2017
# License: GNU GPL v2 or later
# email: r.j.j.h.vanson@gmail.com
# 
#
# Initialization
uiLanguage$ = "NL"
.defaultLanguage = 2
.sp_default = 1
output_table$ = ""
input_file$ = "chunkslist.tsv"
input_file$ = ""
input_table = -1
.continue = 1
# The input table should have tab separated columns labeled: 
# Title, Speaker, File, Language, Log
# An example would be a tab separated list:
# F40L2VT2 F NL chunks/F40L/F40L2VT1.aifc ~/Desktop/results.tsv
# All files are used AS IS, and nothing is drawn
if input_file$ <> "" and fileReadable(input_file$) and index_regex(input_file$, "(?i\.(tsv|Table))")
	input_table = Read Table from tab-separated file: input_file$
endif

# When using a microphone:
.input$ = "Microphone"
.samplingFrequency = 44100
.recordingTime = 4

# Define Language
language$ = "NL"
numVowels = 12
vowelList$ [1] = "i"
vowelList$ [2] = "I"
vowelList$ [3] = "e"
vowelList$ [4] = "E"
vowelList$ [5] = "a"
vowelList$ [6] = "A"
vowelList$ [7] = "O"
vowelList$ [8] = "o"
vowelList$ [9] = "u"
vowelList$ [10] = "y"
vowelList$ [11] = "Y"
vowelList$ [12] = "@"

color$ ["a"] = "Red"
color$ ["i"] = "Green"
color$ ["u"] = "Blue"
color$ ["@"] = "{0.8,0.8,0.8}"

# UI messages and texts
# English
uiMessage$ ["EN", "PauseRecord"] = "Record continuous speech"
uiMessage$ ["EN", "Record1"] = "Record the %%continuous speech%"
uiMessage$ ["EN", "Record2"] = "Please be ready to start"
uiMessage$ ["EN", "Record3"] = "Select the speech you want to analyse"
uiMessage$ ["EN", "Open1"] = "Open the recording containing the speech"
uiMessage$ ["EN", "Open2"] = "Select the speech you want to analyse"
uiMessage$ ["EN", "Corneri"] = "h%%ea%t"
uiMessage$ ["EN", "Corneru"] = "h%%oo%t"
uiMessage$ ["EN", "Cornera"] = "h%%a%t"
uiMessage$ ["EN", "DistanceTitle"] = "Rel. Distance"
uiMessage$ ["EN", "AreaTitle"] = "Rel. Area"
uiMessage$ ["EN", "Area1"] = "1"
uiMessage$ ["EN", "Area2"] = "2"
uiMessage$ ["EN", "AreaN"] = "N"

uiMessage$ ["EN", "LogFile"] = "Write log to table (""-"" write to the info window)"
uiMessage$ ["EN", "CommentContinue"] = "Click on ""Continue"" if you want to analyze more speech samples"
uiMessage$ ["EN", "CommentOpen"] = "Click on ""Open"" and select a recording"
uiMessage$ ["EN", "CommentRecord"] = "Click on ""Record"" and start speaking"
uiMessage$ ["EN", "CommentList"] = "Record sound, ""Save to list & Close"", then click ""Continue"""
uiMessage$ ["EN", "SavePicture"] = "Save picture"
uiMessage$ ["EN", "DoContinue"] = "Do you want to continue?"
uiMessage$ ["EN", "SelectSound1"] = "Select the sound and continue"
uiMessage$ ["EN", "SelectSound2"] = "It is possible to remove unwanted sounds from the selection"
uiMessage$ ["EN", "SelectSound3"] = "Select the unwanted part and then chose ""Cut"" from the ""Edit"" menu"
uiMessage$ ["EN", "Stopped"] = "Vowel Triangle stopped"
uiMessage$ ["EN", "ErrorSound"] = "Error: Not a sound "

uiMessage$ ["EN", "Continue"] = "Continue"
uiMessage$ ["EN", "Done"] = "Done"
uiMessage$ ["EN", "Stop"] = "Stop"
uiMessage$ ["EN", "Open"] = "Open"
uiMessage$ ["EN", "Record"] = "Record"

# Dutch
uiMessage$ ["NL", "PauseRecord"] = "Neem lopende spraak op"
uiMessage$ ["NL", "Record1"] = "Neem de %%lopende spraak% op"
uiMessage$ ["NL", "Record2"] = "Zorg dat u klaar ben om te spreken"
uiMessage$ ["NL", "Record3"] = "Selecteer de spraak die u wilt analyseren"
uiMessage$ ["NL", "Open1"] = "Open de spraakopname"
uiMessage$ ["NL", "Open2"] = "Selecteer de spraak die u wilt analyseren"
uiMessage$ ["NL", "Corneri"] = "h%%ie%t"
uiMessage$ ["NL", "Corneru"] = "h%%oe%d"
uiMessage$ ["NL", "Cornera"] = "h%%aa%t"
uiMessage$ ["NL", "DistanceTitle"] = "Rel. Afstand"
uiMessage$ ["NL", "AreaTitle"] = "Rel. Oppervlak"
uiMessage$ ["NL", "Area1"] = "1"
uiMessage$ ["NL", "Area2"] = "2"
uiMessage$ ["NL", "AreaN"] = "N"

uiMessage$ ["NL", "LogFile"] = "Schrijf resultaten naar log bestand (""-"" schrijft naar info venster)"
uiMessage$ ["NL", "CommentContinue"] = "Klik op ""Doorgaan"" als u meer spraakopnamen wilt analyseren"
uiMessage$ ["NL", "CommentOpen"] = "Klik op ""Open"" en selecteer een opname"
uiMessage$ ["NL", "CommentRecord"] = "Klik op ""Opnemen"" en start met spreken"
uiMessage$ ["NL", "CommentList"] = "Spraak opnemen, ""Save to list & Close"", daarna klik op ""Continue"""
uiMessage$ ["NL", "SavePicture"] = "Bewaar afbeelding"
uiMessage$ ["NL", "DoContinue"] = "Wilt u doorgaan?"
uiMessage$ ["NL", "SelectSound1"] = "Selecteer het spraakfragment en ga door"
uiMessage$ ["NL", "SelectSound2"] = "Het is mogelijk om ongewenste geluiden uit de opname te verwijderen"
uiMessage$ ["NL", "SelectSound3"] = "Selecteer het ongewenste deel en kies ""Cut"" in het ""Edit"" menue"
uiMessage$ ["NL", "Stopped"] = "Vowel Triangle is gestopt"
uiMessage$ ["NL", "ErrorSound"] = "Fout: Dit is geen geluid "

uiMessage$ ["NL", "Continue"] = "Doorgaan"
uiMessage$ ["NL", "Done"] = "Klaar"
uiMessage$ ["NL", "Stop"] = "Stop"
uiMessage$ ["NL", "Open"] = "Open"
uiMessage$ ["NL", "Record"] = "Opnemen"

# Male
phonemes ["NL", "M", "i_corner", "F1"] = 280
phonemes ["NL", "M", "i_corner", "F2"] = 2400
phonemes ["NL", "M", "a_corner", "F1"] = 850
phonemes ["NL", "M", "a_corner", "F2"] = 1350
phonemes ["NL", "M", "u_corner", "F1"] = 280
phonemes ["NL", "M", "u_corner", "F2"] = 600
# @_center is not fixed but derived from current corners
phonemes ["NL", "M", "@_center", "F1"] =(phonemes ["NL", "M", "i_corner", "F1"]*phonemes ["NL", "M", "u_corner", "F1"]*phonemes ["NL", "M", "a_corner", "F1"])^(1/3)
phonemes ["NL", "M", "@_center", "F2"] = (phonemes ["NL", "M", "i_corner", "F2"]*phonemes ["NL", "M", "u_corner", "F2"]*phonemes ["NL", "M", "a_corner", "F2"])^(1/3)

# Formant values according to 
# Weenink, D. J. M. "Formant analysis of Dutch vowels from 10 children." 
# Proc. Institute of Phonetic Sciences University of Amsterdam. 
# Vol. 9. 1985.
# Values taken from: Praat
phonemes ["NL", "M", "i", "F1"] = 285.9
phonemes ["NL", "M", "i", "F2"] = 2219.2
phonemes ["NL", "M", "I", "F1"] = 384.2
phonemes ["NL", "M", "I", "F2"] = 2121.0
phonemes ["NL", "M", "e", "F1"] = 442.3
phonemes ["NL", "M", "e", "F2"] = 2035.2
phonemes ["NL", "M", "E", "F1"] = 581.6
phonemes ["NL", "M", "E", "F2"] = 1872.5
phonemes ["NL", "M", "a", "F1"] = 797.7
phonemes ["NL", "M", "a", "F2"] = 1339.9
phonemes ["NL", "M", "A", "F1"] = 682.4
phonemes ["NL", "M", "A", "F2"] = 1069.1
phonemes ["NL", "M", "O", "F1"] = 475.5
phonemes ["NL", "M", "O", "F2"] = 734.5
phonemes ["NL", "M", "o", "F1"] = 483.5
phonemes ["NL", "M", "o", "F2"] = 857.5
phonemes ["NL", "M", "u", "F1"] = 317.6
phonemes ["NL", "M", "u", "F2"] = 670.7
phonemes ["NL", "M", "y", "F1"] = 301.5
phonemes ["NL", "M", "y", "F2"] = 1671.7
phonemes ["NL", "M", "Y", "F1"] = 431.9
phonemes ["NL", "M", "Y", "F2"] = 1512.1
# Guessed
phonemes ["NL", "M", "@", "F1"] = 458.5
phonemes ["NL", "M", "@", "F2"] = 1513.8

# Female
phonemes ["NL", "F", "i_corner", "F1"] = 290
phonemes ["NL", "F", "i_corner", "F2"] = 2800
phonemes ["NL", "F", "a_corner", "F1"] = 1000
phonemes ["NL", "F", "a_corner", "F2"] = 1530
phonemes ["NL", "F", "u_corner", "F1"] = 290
phonemes ["NL", "F", "u_corner", "F2"] = 630
# @_center is not fixed but derived from current corners
phonemes ["NL", "F", "@_center", "F1"] =(phonemes ["NL", "F", "i_corner", "F1"]*phonemes ["NL", "F", "u_corner", "F1"]*phonemes ["NL", "F", "a_corner", "F1"])^(1/3)
phonemes ["NL", "F", "@_center", "F2"] = (phonemes ["NL", "F", "i_corner", "F2"]*phonemes ["NL", "F", "u_corner", "F2"]*phonemes ["NL", "F", "a_corner", "F2"])^(1/3)

# Weenink, D. J. M. "Formant analysis of Dutch vowels from 10 children." 
# Proc. Institute of Phonetic Sciences University of Amsterdam. 
# Vol. 9. 1985.
# Values taken from: Praat
phonemes ["NL", "F", "i", "F1"] = 295.5
phonemes ["NL", "F", "i", "F2"] = 2519.5
phonemes ["NL", "F", "I", "F1"] = 459.2
phonemes ["NL", "F", "I", "F2"] = 2373.3
phonemes ["NL", "F", "e", "F1"] = 487.8
phonemes ["NL", "F", "e", "F2"] = 2304.1
phonemes ["NL", "F", "E", "F1"] = 650.7
phonemes ["NL", "F", "E", "F2"] = 2121.2
phonemes ["NL", "F", "a", "F1"] = 914.1
phonemes ["NL", "F", "a", "F2"] = 1534.5
phonemes ["NL", "F", "A", "F1"] = 816.5
phonemes ["NL", "F", "A", "F2"] = 1219.5
phonemes ["NL", "F", "O", "F1"] = 580.2
phonemes ["NL", "F", "O", "F2"] = 876.9
phonemes ["NL", "F", "o", "F1"] = 556.2
phonemes ["NL", "F", "o", "F2"] = 976.4
phonemes ["NL", "F", "u", "F1"] = 331.4
phonemes ["NL", "F", "u", "F2"] = 705.8
phonemes ["NL", "F", "y", "F1"] = 308.0
phonemes ["NL", "F", "y", "F2"] = 1828.1
phonemes ["NL", "F", "Y", "F1"] = 477.9
phonemes ["NL", "F", "Y", "F2"] = 1749.1
# Guessed
phonemes ["NL", "F", "@", "F1"] = 500.5
phonemes ["NL", "F", "@", "F2"] = 1706.6

# Run as a non interactive program
if input_table > 0
	selectObject: input_table
	.numInputRows = Get number of rows
	for .r to .numInputRows
		selectObject: input_table
		title$ = Get value: .r, "Title"
		.sp$ = Get value: .r, "Speaker"
		file$ = Get value: .r, "File"
		tmp$ = Get value: .r, "Language"
		if index(tmp$, "[A-Z]{2}")
			uiLanguage$ = tmp$
		endif
		if index_regex(tmp$, "[-\w]")
			output_table$ = Get value: .r, "Log"
			if not fileReadable(output_table$)
				writeFileLine: output_table$, "Name", tab$, "Speaker", tab$, "N", tab$, "Area", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist"
			endif
		endif
		if file$ <> "" and fileReadable(file$) and index_regex(file$, "(?i\.(wav|mp3|aif[fc]))")
			tmp = Read from file: file$
			if tmp <= 0 or numberOfSelected("Sound") <= 0
				exitScript: "Not a valid Sound file"
			endif
			name$ = selected$("Sound")
			.sound = Convert to mono
			Rename: name$
			selectObject(tmp)
			Remove
		else
			exitScript: "Not a valid file"
		endif
		@plot_vowels: 0, .sp$, .sound
		@print_output_line: title$, .sp$, plot_vowels.numVowelIntervals, plot_vowels.area2perc, plot_vowels.relDist_i, plot_vowels.relDist_u, plot_vowels.relDist_a
		
		selectObject: .sound
		Remove
	endfor
	selectObject: input_table
	Remove
	
	exitScript: "Ready"
endif

# Run master loop
while .continue
	
	.recording = 0
	beginPause: "Select a recording"
		sentence: "Title", "untitled"
		comment: uiMessage$ [uiLanguage$, "CommentOpen"]
		comment: uiMessage$ [uiLanguage$, "CommentRecord"]
		choice: "Speaker is a", .sp_default
			option: "Female"
			option: "Male"
		optionMenu: "Display language", .defaultLanguage
			option: "English"
			option: "Nederlands"
		boolean: "Log", (output_table$ <> "")
	.clicked = endPause: (uiMessage$ [uiLanguage$, "Stop"]), (uiMessage$ [uiLanguage$, "Record"]), (uiMessage$ [uiLanguage$, "Open"]), 3, 1
	if .clicked = 1
		.continue = 0
		@exitVowelTriangle: "Nothing to do"
	elsif .clicked = 2
		.recording = 1
	endif
	.sp$ = "M"
	.sp_default = 2
	if speaker_is_a$ = "Female"
		.sp$ = "F"
		.sp_default = 1
	endif
	uiLanguage$ = "EN"
	.defaultLanguage = 1
	if display_language$ = "Nederlands"
		uiLanguage$ = "NL"
		.defaultLanguage = 2
	endif
	if log and output_table$ = ""
		Erase all
		Select inner viewport: 0.5, 7.5, 0.5, 4.5
		Axes: 0, 1, 0, 1
		Blue
		Text special: 0, "left", 0.65, "half", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "LogFile"]
		
		output_table$ = chooseWriteFile$: uiMessage$ [uiLanguage$, "LogFile"], replace_regex$(uiMessage$ [uiLanguage$, "LogFile"], "^[^\(]+", "", 0) + " -"
		if endsWith(output_table$, "-")
			output_table$ = "-"
		endif
		# Print output
		if output_table$ = "-"
			clearinfo
			appendInfoLine: "Name", tab$, "Speaker", tab$, "N", tab$, "Area", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist"
		elsif index_regex(output_table$, "\w") and not fileReadable(output_table$)
			writeFileLine: output_table$, "Name", tab$, "Speaker", tab$, "N", tab$, "Area", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist"
		endif
	endif
	
	# Write instruction
	Erase all
	Select inner viewport: 0.5, 7.5, 0.5, 4.5
	Axes: 0, 1, 0, 1
	Blue
	if .recording
		Text special: 0, "left", 0.65, "half", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "Record1"]
		Text special: 0, "left", 0.45, "half", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "Record2"]	
	else
		Text special: 0, "left", 0.65, "half", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "Record3"]
	endif
	Black
	
	# Open sound and select
	.open1$ = uiMessage$ [uiLanguage$, "Open1"]
	.open2$ = uiMessage$ [uiLanguage$, "Open2"]
	@read_and_select_audio: .recording, .open1$ , .open2$
	.sound = read_and_select_audio.sound
	if title$ = "untitled"
		title$ = replace_regex$(read_and_select_audio.filename$, "\.[^\.]+$", "", 0)
		title$ = replace_regex$(title$, "^.*/([^/]+)$", "\1", 0)
	endif
		
	# Draw vowel triangle
	Erase all
	call set_up_Canvas
	call plot_vowel_triangle '.sp$'
	Text special... 0.5 Centre 1.05 bottom Helvetica 18 0 %%'title$'%
	
	selectObject: .sound
	.intensity = Get intensity (dB)
	if .intensity > 50
		@plot_vowels: 1, .sp$, .sound, 
		@print_output_line: title$, .sp$, plot_vowels.numVowelIntervals, plot_vowels.area2perc, plot_vowels.relDist_i, plot_vowels.relDist_u, plot_vowels.relDist_a
	endif
	
	selectObject: .sound
	Remove
	
	
	# Save graphics
	.file$ = chooseWriteFile$: uiMessage$ [uiLanguage$, "SavePicture"], title$+"_VowelTriangle.png"
	if .file$ <> ""
		Save as 300-dpi PNG file: .file$
	endif
	
	# Ready or not?
	beginPause: uiMessage$ [uiLanguage$, "DoContinue"]
		comment: uiMessage$ [uiLanguage$, "CommentContinue"]
	.clicked = endPause: (uiMessage$ [uiLanguage$, "Continue"]), (uiMessage$ [uiLanguage$, "Done"]), 2, 2
	.continue = (.clicked = 1)
	
endwhile

#####################################################################

procedure read_and_select_audio .type .message1$ .message2$
	if .type
		Record mono Sound...
		beginPause: (uiMessage$ [uiLanguage$, "PauseRecord"])
			comment: uiMessage$ [uiLanguage$, "CommentList"]
		.clicked = endPause: (uiMessage$ [uiLanguage$, "Stop"]), (uiMessage$ [uiLanguage$, "Continue"]), 2, 1
		if .clicked = 1
			@exitVowelTriangle: "Vowel Triangle stopped"
		endif
		if numberOfSelected("Sound") <= 0
			@exitVowelTriangle: (uiMessage$ [uiLanguage$, "ErrorSound"])
		endif
		.source = selected ("Sound")
		.filename$ = "Recorded speech"
	else
		.filename$ = chooseReadFile$: .message1$
		if .filename$ = "" or not fileReadable(.filename$) or not index_regex(.filename$, "(?i\.(wav|mp3|aif[fc]))")
			@exitVowelTriangle: "No readable recording selected "+.filename$
		endif
		
		.source = Open long sound file: .filename$
		.filename$ = selected$("LongSound")
		.fullName$ = selected$()
		.fileType$ = extractWord$ (.fullName$, "")
		if .fileType$ <> "Sound" and .fileType$ <> "LongSound"
			@exitVowelTriangle:  (uiMessage$ [uiLanguage$, "ErrorSound"])+.filename$
		endif
	endif
	
	selectObject: .source
	.fullName$ = selected$()
	.duration = Get total duration
	if startsWith(.fullName$, "Sound") 
		View & Edit
	else
		View
	endif
	editor: .source
	endeditor
	beginPause: .message2$
		comment: (uiMessage$ [uiLanguage$, "SelectSound1"])
		comment: (uiMessage$ [uiLanguage$, "SelectSound2"])
		comment: (uiMessage$ [uiLanguage$, "SelectSound3"])
	.clicked = endPause: (uiMessage$ [uiLanguage$, "Stop"]), (uiMessage$ [uiLanguage$, "Continue"]), 2, 1
	if .clicked = 1
		@exitVowelTriangle: (uiMessage$ [uiLanguage$, "Stopped"])
	endif
	
	editor: .source
		.start = Get start of selection
		.end = Get end of selection
		if .start >= .end
			Select: 0, .duration
		endif
		Extract selected sound (time from 0)
	endeditor
	.tmp = selected ()
	if .tmp <= 0
		selectObject: .source
		.duration = Get total duration
		.tmp = Extract part: 0, .duration, "yes"
	endif
	
	# Recordings can be in Stereo, change to mono
	selectObject: .tmp
	.sound = Convert to mono
	selectObject: .tmp, .source
	Remove

	selectObject: .sound
	Rename: .filename$
endproc

# Set up Canvas
procedure set_up_Canvas
	Select outer viewport: 0, 8, 0, 8
	Select inner viewport: 0.75, 7.25, 0.75, 7.25
	Axes: 0, 1, 0, 1
	Solid line
	Black
	Line width: 1.0
endproc

# Plot the vowels in a sound
# .plot: Actually plot inside icture window or just calculate paramters
procedure plot_vowels .plot .sp$ .sound
	.startT = 0 
	#call syllable_nuclei -25 4 0.3 1 .sound
	#.syllableKernels = syllable_nuclei.textgridid
	call segment_syllables -25 4 0.3 1 .sound
	.syllableKernels = segment_syllables.textgridid
	
	# Calculate the formants
	selectObject: .sound
	.soundname$ = selected$("Sound")
	.downSampled = Resample: 11000, 50
	.formants = noprogress To Formant (sl): 0, 5, 5500, 0.025, 50

	call select_vowel_target .sound .formants .syllableKernels
	.vowelTier = select_vowel_target.vowelTier
	.targetTier = select_vowel_target.targetTier
	
	# Set new @_center
	phonemes [language$, .sp$, "@_center", "F1"] = (phonemes [language$, .sp$, "a", "F1"] * phonemes [language$, .sp$, "i", "F1"] * phonemes [language$, .sp$, "u", "F1"]) ** (1/3) 
	phonemes [language$, .sp$, "@_center", "F2"] = (phonemes [language$, .sp$, "a", "F2"] * phonemes [language$, .sp$, "i", "F2"] * phonemes [language$, .sp$, "u", "F2"]) ** (1/3) 
	
	selectObject: .syllableKernels
	.f1_c = phonemes [language$, .sp$, "@_center", "F1"]
	.f2_c = phonemes [language$, .sp$, "@_center", "F2"]
	
	# Plot center
	@vowel2point: .sp$, .f1_c, .f2_c
	.st_c1 = vowel2point.x
	.st_c2 = vowel2point.y
	
	# Near /@/
	.f1_c = phonemes [language$, .sp$, "@_center", "F1"]
	.f2_c = phonemes [language$, .sp$, "@_center", "F2"]
	@get_closest_vowels: .sp$, .formants, .syllableKernels, .f1_c, .f2_c
	.numVowelIntervals = get_closest_vowels.vowelNum
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["@"], .x, .y, 0.01
		endfor
	endif
	
	# Near /i/
	.f1_i = phonemes [language$, .sp$, "i", "F1"]
	.f2_i = phonemes [language$, .sp$, "i", "F2"]
	@get_closest_vowels: .sp$, .formants, .syllableKernels, .f1_i, .f2_i
	.meanDistToCenter ["i"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["i"] = get_closest_vowels.stdevDistance
	
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["i"], .x, .y, 0.01
		endfor
	endif
	
	# Near /u/
	.f1_u = phonemes [language$, .sp$, "u", "F1"]
	.f2_u = phonemes [language$, .sp$, "u", "F2"]
	@get_closest_vowels: .sp$, .formants, .syllableKernels, .f1_u, .f2_u
	.meanDistToCenter ["u"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["u"] = get_closest_vowels.stdevDistance
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["u"], .x, .y, 0.01
		endfor
	endif
	
	# Near /a/
	.f1_a = phonemes [language$, .sp$, "a", "F1"]
	.f2_a = phonemes [language$, .sp$, "a", "F2"]
	@get_closest_vowels: .sp$, .formants, .syllableKernels, .f1_a, .f2_a
	.meanDistToCenter ["a"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["a"] = get_closest_vowels.stdevDistance
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["a"], .x, .y, 0.01
		endfor
	endif
	
	# Print center and corner markers
	# Center
	if .plot
		.x = .st_c1
		.y = .st_c2
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
		# u
		@vowel2point: .sp$, .f1_u, .f2_u	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
		# i
		@vowel2point: .sp$, .f1_i, .f2_i	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
		# a
		@vowel2point: .sp$, .f1_a, .f2_a	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
	endif
	
	# Draw new triangle
	@vowel2point: .sp$, .f1_i, .f2_i
	.st_i1 = vowel2point.x
	.st_i2 = vowel2point.y
	.ic_dist = sqrt((.st_c1 - .st_i1)^2 + (.st_c2 - .st_i2)^2)
	@vowel2point: .sp$, .f1_u, .f2_u
	.st_u1 = vowel2point.x
	.st_u2 = vowel2point.y
	.uc_dist = sqrt((.st_c1 - .st_u1)^2 + (.st_c2 - .st_u2)^2)
	@vowel2point: .sp$, .f1_a, .f2_a
	.st_a1 = vowel2point.x
	.st_a2 = vowel2point.y
	.ac_dist = sqrt((.st_c1 - .st_a1)^2 + (.st_c2 - .st_a2)^2)
	
	# Vowel tirangle surface area (Heron's formula)
	.auDist = sqrt((.st_a1 - .st_u1)^2 + (.st_a2 - .st_u2)^2)
	.aiDist = sqrt((.st_a1 - .st_i1)^2 + (.st_a2 - .st_i2)^2)
	.uiDist = sqrt((.st_u1 - .st_i1)^2 + (.st_u2 - .st_i2)^2)
	.p = (.auDist + .aiDist + .uiDist)/2
	.areaVT = sqrt(.p * (.p - .auDist) * (.p - .aiDist) * (.p - .uiDist))

	# 1 stdev
	# c - i
	.relDist = (.meanDistToCenter ["i"] + .stdevDistToCenter ["i"]) / .ic_dist
	.x ["i"] = .st_c1 + .relDist * (.st_i1 - .st_c1)
	.y ["i"] = .st_c2 + .relDist * (.st_i2 - .st_c2)
	# c - u
	.relDist = (.meanDistToCenter ["u"] + .stdevDistToCenter ["u"]) / .uc_dist
	.x ["u"] = .st_c1 + .relDist * (.st_u1 - .st_c1)
	.y ["u"] = .st_c2 + .relDist * (.st_u2 - .st_c2)
	# c - a
	.relDist = (.meanDistToCenter ["a"] + .stdevDistToCenter ["a"]) / .ac_dist
	.x ["a"] = .st_c1 + .relDist * (.st_a1 - .st_c1)
	.y ["a"] = .st_c2 + .relDist * (.st_a2 - .st_c2)
	
	if .plot
		Black
		Dotted line
		Draw line: .x ["a"], .y ["a"], .x ["i"], .y ["i"]
		Draw line: .x ["i"], .y ["i"], .x ["u"], .y ["u"]
		Draw line: .x ["u"], .y ["u"], .x ["a"], .y ["a"]
	endif

	# Vowel tirangle surface area (Heron's formula)
	.auDist = sqrt((.x ["a"] - .x ["u"])^2 + (.y ["a"] - .y ["u"])^2)
	.aiDist = sqrt((.x ["a"] - .x ["i"])^2 + (.y ["a"] - .y ["i"])^2)
	.uiDist = sqrt((.x ["u"] - .x ["i"])^2 + (.y ["u"] - .y ["i"])^2)
	.p = (.auDist + .aiDist + .uiDist)/2
	.areaSD1 = sqrt(.p * (.p - .auDist) * (.p - .aiDist) * (.p - .uiDist))
	.area1perc = 100*(.areaSD1 / .areaVT)

	# 2 stdev
	# c - i
	.relDist_i = (.meanDistToCenter ["i"] + 2 * .stdevDistToCenter ["i"]) / .ic_dist
	.x ["i"] = .st_c1 + .relDist_i * (.st_i1 - .st_c1)
	.y ["i"] = .st_c2 + .relDist_i * (.st_i2 - .st_c2)
	# c - u
	.relDist_u = (.meanDistToCenter ["u"] + 2 * .stdevDistToCenter ["u"]) / .uc_dist
	.x ["u"] = .st_c1 + .relDist_u * (.st_u1 - .st_c1)
	.y ["u"] = .st_c2 + .relDist_u * (.st_u2 - .st_c2)
	# c - a
	.relDist_a = (.meanDistToCenter ["a"] + 2 * .stdevDistToCenter ["a"]) / .ac_dist
	.x ["a"] = .st_c1 + .relDist_a * (.st_a1 - .st_c1)
	.y ["a"] = .st_c2 + .relDist_a * (.st_a2 - .st_c2)
	# Convert to percentages
	.relDist_i *= 100
	.relDist_u *= 100
	.relDist_a *= 100
	
	if .plot
		Black
		Solid line
		Draw line: .x ["a"], .y ["a"], .x ["i"], .y ["i"]
		Draw line: .x ["i"], .y ["i"], .x ["u"], .y ["u"]
		Draw line: .x ["u"], .y ["u"], .x ["a"], .y ["a"]
	endif

	# Vowel tirangle surface area (Heron's formula)
	.auDist = sqrt((.x ["a"] - .x ["u"])^2 + (.y ["a"] - .y ["u"])^2)
	.aiDist = sqrt((.x ["a"] - .x ["i"])^2 + (.y ["a"] - .y ["i"])^2)
	.uiDist = sqrt((.x ["u"] - .x ["i"])^2 + (.y ["u"] - .y ["i"])^2)
	.p = (.auDist + .aiDist + .uiDist)/2
	.areaSD2 = sqrt(.p * (.p - .auDist) * (.p - .aiDist) * (.p - .uiDist))
	.area2perc = 100*(.areaSD2 / .areaVT)

	# Print areas as percentage
	if .plot
		Text special: 1, "right", 0.15, "bottom", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "AreaTitle"]
		Text special: 0.9, "right", 0.1, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "Area1"]
		Text special: 0.9, "left", 0.1, "bottom", "Helvetica", 14, "0", ": '.area1perc:0'\% "
		Text special: 0.9, "right", 0.05, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "Area2"]
		Text special: 0.9, "left", 0.05, "bottom", "Helvetica", 14, "0", ": '.area2perc:0'\% "
		Text special: 0.9, "right", 0.00, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "AreaN"]
		Text special: 0.9, "left", 0.00, "bottom", "Helvetica", 14, "0", ": '.numVowelIntervals'"

		# Relative distance to corners
		Text special: 0, "left", 0.15, "bottom", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "DistanceTitle"]
		Text special: 0, "left", 0.10, "bottom", "Helvetica", 14, "0", "/i/: '.relDist_i:0'\% "
		Text special: 0, "left", 0.05, "bottom", "Helvetica", 14, "0", "/u/: '.relDist_u:0'\% "
		Text special: 0, "left", 0.00, "bottom", "Helvetica", 14, "0", "/a/: '.relDist_a:0'\% "
	endif
	
	selectObject: .downSampled, .formants, .syllableKernels
	Remove
endproc

procedure print_output_line .title$, .sp$, .numVowelIntervals, .area2perc, .relDist_i, .relDist_u, .relDist_a
	# Uses global variable
	if output_table$ = "-"
		appendInfoLine: title$, tab$, .sp$, tab$, .numVowelIntervals, tab$, fixed$(.area2perc, 0), tab$, fixed$(.relDist_i, 0), tab$, fixed$(.relDist_u, 0), tab$, fixed$(.relDist_a, 0)
	elsif index_regex(output_table$, "\w")
		appendFileLine: output_table$, title$, tab$, .sp$, tab$, .numVowelIntervals, tab$, fixed$(.area2perc, 0), tab$, fixed$(.relDist_i, 0), tab$, fixed$(.relDist_u, 0), tab$, fixed$(.relDist_a, 0)
	endif	
endproc

# Plot the standard vowels
procedure plot_standard_vowel .color$ .sp$ .vowel$ .reduction
	.vowel$ = replace_regex$(.vowel$, "v", "y", 0)

	.i = 0
	while .vowel$ <> ""
		.i += 1
		.v$ = replace_regex$(.vowel$, "^\s*(\S[`]?).*$", "\1", 0)
		.f1 = phonemes [language$, .sp$, .v$, "F1"]
		.f2 = phonemes [language$, .sp$, .v$, "F2"]
		if .reduction
			.factor = 0.9^.reduction
			.f1 = .factor * (.f1 - phonemes [language$, .sp$, "@", "F1"]) + phonemes [language$, .sp$, "@", "F1"]
			.f2 = .factor * (.f2 - phonemes [language$, .sp$, "@", "F2"]) + phonemes [language$, .sp$, "@", "F2"]
		endif
		@vowel2point: .sp$, .f1, .f2
		.x [.i] = vowel2point.x
		.y [.i] = vowel2point.y
		.vowel$ = replace_regex$(.vowel$, "^\s*(\S[`]?)", "", 0)
	endwhile
	Arrow size: 2
	Green
	Dotted line
	Paint circle: .color$, .x[1], .y[1], 1
	for .p from 2 to .i
		Draw arrow: .x[.p - 1], .y[.p - 1], .x[.p], .y[.p]
	endfor
	demoShow()
	Black
endproc

# Plot the vowel triangle
procedure plot_vowel_triangle .sp$
	# Draw vowel triangle
	.a_F1 = phonemes [language$, .sp$, "a_corner", "F1"]
	.a_F2 = phonemes [language$, .sp$, "a_corner", "F2"]

	.i_F1 = phonemes [language$, .sp$, "i_corner", "F1"]
	.i_F2 = phonemes [language$, .sp$, "i_corner", "F2"]

	.u_F1 = phonemes [language$, .sp$, "u_corner", "F1"]
	.u_F2 = phonemes [language$, .sp$, "u_corner", "F2"]
	
	Dashed line
	# u - i
	@vowel2point: .sp$, .u_F1, .u_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	Colour: color$ ["u"]
	Text special: .x1, "Centre", .y1, "Bottom", "Helvetica", 20, "0", "/u/ "+uiMessage$ [uiLanguage$, "Corneru"]
	Black
	
	@vowel2point: .sp$, .i_F1, .i_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Colour: color$ ["i"]
	Text special: .x2, "Centre", .y2, "Bottom", "Helvetica", 20, "0", uiMessage$ [uiLanguage$, "Corneri"]+" /i/"
	Black
	Draw line: .x1, .y1, .x2, .y2
	
	# u - a
	@vowel2point: .sp$, .u_F1, .u_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	@vowel2point: .sp$, .a_F1, .a_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Colour: color$ ["a"]
	Text special: .x2, "Centre", .y2, "Top", "Helvetica", 20, "0", "/a/ "+uiMessage$ [uiLanguage$, "Cornera"]
	Black
	Draw line: .x1, .y1, .x2, .y2
	
	# i - a
	@vowel2point: .sp$, .i_F1, .i_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	@vowel2point: .sp$, .a_F1, .a_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Draw line: .x1, .y1, .x2, .y2
endproc

# Convert the frequencies to coordinates
procedure vowel2point .sp$ .f1 .f2
	.spt1 = 12*log2(.f1)
	.spt2 = 12*log2(.f2)
	
	.a_St1 = 12*log2(phonemes [language$, .sp$, "a_corner", "F1"])
	.a_St2 = 12*log2(phonemes [language$, .sp$, "a_corner", "F2"])

	.i_St1 = 12*log2(phonemes [language$, .sp$, "i_corner", "F1"])
	.i_St2 = 12*log2(phonemes [language$, .sp$, "i_corner", "F2"])

	.u_St1 = 12*log2(phonemes [language$, .sp$, "u_corner", "F1"])
	.u_St2 = 12*log2(phonemes [language$, .sp$, "u_corner", "F2"])

	.x = ((.i_St2 - .spt2)/(.i_St2 - .u_St2))
	.y = (1 - (.spt1 - min(.u_St1, .i_St1))/(.a_St1 - min(.u_St1, .i_St1)))
	
endproc

# Stop the progam
procedure exitVowelTriangle .message$
	select all
	if numberOfSelected() > 0
		Remove
	endif
	exitScript: .message$
endproc

# Get a list of best targets with distances, one for each vowel segment found
# Use DTW to get the best match
procedure get_closest_vowels .sp$ .formants .textgrid .f1_o .f2_o
	.f1 = 0
	.f2 = 0
	
	# Convert to coordinates
	@vowel2point: .sp$, .f1_o, .f2_o
	.st_o1 = vowel2point.x
	.st_o2 = vowel2point.y
	
	# Get center coordinates
	.fc1 = phonemes ["NL", .sp$, "@_center", "F1"]
	.fc2 = phonemes ["NL", .sp$, "@_center", "F2"]
	@vowel2point: .sp$, .fc1, .fc2
	.st_c1 = vowel2point.x
	.st_c2 = vowel2point.y
	.tcDist_sqr = (.st_o1 - .st_c1)^2 + (.st_o2 - .st_c2)^2

	.vowelTier = 1
	.vowelNum = 0
	selectObject: .textgrid
	.numIntervals = Get number of intervals: .vowelTier
	.tableDistances = -1
	for .i to .numIntervals
		selectObject: .textgrid
		.label$ = Get label of interval: .vowelTier, .i
		if .label$ = "Vowel"
			.numDistance = 100000000000
			.numF1 = -1
			.numF2 = -1
			.num_t = 0
			selectObject: .textgrid
			.start = Get start time of interval: .vowelTier, .i
			.end = Get end time of interval: .vowelTier, .i
			selectObject: .formants
			.t = .start
			while .t <= .end
				.ftmp1 = Get value at time: 1, .t, "Hertz", "Linear"
				.ftmp2 = Get value at time: 2, .t, "Hertz", "Linear"
				@vowel2point: .sp$, .ftmp1, .ftmp2
				.stmp1 = vowel2point.x
				.stmp2 = vowel2point.y
				.tmpdistsqr = (.st_o1 - .stmp1)^2 + (.st_o2 - .stmp2)^2
				# Local
				if .tmpdistsqr < .numDistance
					.numDistance = .tmpdistsqr
					.numF1 = .ftmp1
					.numF2 = .ftmp2
					.num_t = .t
				endif
				.t += 0.005
			endwhile
			
			
			# Calculate the distance along the line between the 
			# center (c) and the target (t) from the best match 'v'
			# to the center.
			# 
			@vowel2point: .sp$, .numF1, .numF2
			.st1 = vowel2point.x
			.st2 = vowel2point.y
			
			.vcDist_sqr = (.st_c1 - .st1)^2 + (.st_c2 - .st2)^2
			.vtDist_sqr = (.st_o1 - .st1)^2 + (.st_o2 - .st2)^2
			.cvDist = (.tcDist_sqr + .vcDist_sqr - .vtDist_sqr)/(2*sqrt(.tcDist_sqr))
			# Only use positive distances
			if .cvDist = undefined or .cvDist >= 0
				.vowelNum += 1
				.distance_list [.vowelNum] = sqrt(.numDistance)
				.f1_list [.vowelNum] = .numF1
				.f2_list [.vowelNum] = .numF2
				.t_list [.vowelNum] = .num_t
	
				if .tableDistances <= 0
					.tableDistances = Create TableOfReal: "Distances", 1, 1
				else
					selectObject: .tableDistances
					Insert row (index): 1
				endif
				selectObject: .tableDistances
				Set value: 1, 1, .cvDist
			endif
		endif
	endfor
	.meanDistance = -1
	.stdevDistance = -1
	if .tableDistances > 0
		selectObject: .tableDistances
		.meanDistance = Get column mean (index): 1
		.stdevDistance = Get column stdev (index): 1
		Remove
	endif
endproc

# Collect all the most distant vowles
procedure get_most_distant_vowels .sp$ .formants .textgrid .f1_o .f2_o
	.f1 = 0
	.f2 = 0
	
	# Convert to coordinates
	@vowel2point: .sp$, .f1_o, .f2_o
	.st_o1 = vowel2point.x
	.st_o2 = vowel2point.y
	
	.vowelTier = 1
	.vowelNum = 0
	selectObject: .textgrid
	.numIntervals = Get number of intervals: .vowelTier
	for .i to .numIntervals
		selectObject: .textgrid
		.label$ = Get label of interval: .vowelTier, .i
		if .label$ = "Vowel"
			.vowelNum += 1
			.numDistance = -1
			.numF1 = -1
			.numF2 = -1
			.num_t = 0
			selectObject: .textgrid
			.start = Get start time of interval: .vowelTier, .i
			.end = Get end time of interval: .vowelTier, .i
			selectObject: .formants
			.t = .start
			while .t <= .end
				.ftmp1 = Get value at time: 1, .t, "Hertz", "Linear"
				.ftmp2 = Get value at time: 2, .t, "Hertz", "Linear"
				@vowel2point: .sp$, .ftmp1, .ftmp2
				.stmp1 = vowel2point.x
				.stmp2 = vowel2point.y
				.tmpdistsqr = (.st_o1 - .stmp1)^2 + (.st_o2 - .stmp2)^2
				# Local
				if .tmpdistsqr > .numDistance
					.numDistance = .tmpdistsqr
					.numF1 = .ftmp1
					.numF2 = .ftmp2
					.num_t = .t
				endif
				.t += 0.005
			endwhile

			.distance_list [.vowelNum] = sqrt(.numDistance)
			.f1_list [.vowelNum] = .numF1
			.f2_list [.vowelNum] = .numF2
			.t_list [.vowelNum] = .num_t
		endif
	endfor
endproc

procedure select_vowel_target .sound .formants .textgrid
	.f1_Lowest = 270
	.f1_Highest = 1050
	selectObject: .textgrid
	.duration = Get total duration
	.firstTier$ = Get tier name: 1
	if .firstTier$ <> "Vowel"
		Insert point tier: 1, "VowelTarget"
		Insert interval tier: 1, "Vowel"
	endif
	.vowelTier = 1
	.targetTier = 2
	.peakTier = 3
	.valleyTier = 4
	.silencesTier = 5
	.vuvTier = 6

	selectObject: .sound
	.intensity = Get intensity (dB)
	.formantsBurg = noprogress To Formant (burg): 0, 5, 5500, 0.025, 50
	.totalNumFrames = Get number of frames
		
	# Nothing found, but there is sound. Try to find at least 1 vowel
	
	selectObject: .textgrid
	.numPeaks = Get number of points: .peakTier	
	if .numPeaks <= 0 and .intensity >= 45
		selectObject: .downSampled
		.t_max = Get time of maximum: 0, 0, "Sinc70"
		.pp = noprogress To PointProcess (periodic, cc): 75, 600
		.textGrid = noprogress To TextGrid (vuv): 0.02, 0.01
		.i = Get interval at time: 1, .t_max
		.label$ = Get label of interval: 1, .i
		.start = Get start time of interval: 1, .i
		.end = Get end time of interval: 1, .i
		if .label$ = "V"
			selectObject: .syllableKernels
			Insert point: .peakTier, .t_max, "P"
			Insert point: .valleyTier, .start, "V"
			Insert point: .valley, .end, "V"
		endif
	endif
	
	selectObject: .textgrid
	.numPeaks = Get number of points: .peakTier
	.numValleys = Get number of points: .valleyTier
	for .p to .numPeaks
		selectObject: .textgrid
		.tp = Get time of point: .peakTier, .p
		# Find boundaries
		# From valleys
		.tl = 0
		.vl = Get low index from time: .valleyTier, .tp
		if .vl > 0 and .vl < .numValleys
			.tl = Get time of point: .valleyTier, .vl
		endif
		.th = .duration
		.vh = Get high index from time: .valleyTier, .tp
		if .vh > 0 and .vh < .numValleys
			.th = Get time of point: .valleyTier, .vh
		endif
		# From silences
		.sl = Get interval at time: .silencesTier, .tl
		.label$ = Get label of interval: .silencesTier, .sl
		.tsl = .tl
		if .label$ = "silent"
			.tsl = Get end time of interval: .silencesTier, .sl
		endif
		if .tsl > .tl and .tsl < .tp
			.tl = .tsl
		endif
		.sh = Get interval at time: .silencesTier, .th
		.label$ = Get label of interval: .silencesTier, .sh
		.tsh = .th
		if .label$ = "silent"
			.tsh = Get start time of interval: .silencesTier, .sh
		endif
		if .tsh < .th and .tsh > .tp
			.th = .tsh
		endif
		
		# From vuv
		.vuvl = Get interval at time: .vuvTier, .tl
		.label$ = Get label of interval: .vuvTier, .vuvl
		.tvuvl = .tl
		if .label$ = "U"
			.tvuvl = Get end time of interval: .vuvTier, .vuvl
		endif
		if .tvuvl > .tl and .tvuvl < .tp
			.tl = .tvuvl
		endif
		.vuvh = Get interval at time: .vuvTier, .th
		.label$ = Get label of interval: .vuvTier, .vuvh
		.tvuvh = .th
		if .label$ = "U"
			.tvuvh = Get start time of interval: .vuvTier, .vuvh
		endif
		if .tvuvh < .th and .tvuvh > .tp
			.th = .tvuvh
		endif
		
		# From formants: 300 <= F1 <= 1000
		# F1 >= 300
		selectObject: .formants
		.dt = Get time step

		selectObject: .formants
		.f = Get value at time: 1, .tl, "Hertz", "Linear"
		selectObject: .formantsBurg
		.b = Get bandwidth at time: 1, .tl, "Hertz", "Linear"
		.iframe = Get frame number from time: .tl
		if .iframe > .totalNumFrames
			.iframe = .totalNumFrames
		elsif .iframe < 1
			.iframe = 1
		endif
		.nf = Get number of formants: .iframe
		while (.f < .f1_Lowest or .f > .f1_Highest or .b > 0.7 * .f or .nf < 4) and .tl + .dt < .th
			.tl += .dt
			selectObject: .formants
			.f = Get value at time: 1, .tl, "Hertz", "Linear"
			selectObject: .formantsBurg
			.b = Get bandwidth at time: 1, .tl, "Hertz", "Linear"
			.iframe = Get frame number from time: .tl
			.nf = Get number of formants: .iframe		
		endwhile

		selectObject: .formants
		.f = Get value at time: 1, .th, "Hertz", "Linear"
		selectObject: .formantsBurg
		.b = Get bandwidth at time: 1, .th, "Hertz", "Linear"
		.iframe = Get frame number from time: .th
		if .iframe > .totalNumFrames
			.iframe = .totalNumFrames
		endif
		.nf = Get number of formants: .iframe
		while (.f < .f1_Lowest or .f > .f1_Highest or .b > 0.7 * .f or .nf < 4) and .th - .dt > .tl
			.th -= .dt
			selectObject: .formants
			.f = Get value at time: 1, .th, "Hertz", "Linear"
			selectObject: .formantsBurg
			.b = Get bandwidth at time: 1, .th, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			if .iframe > .totalNumFrames
				.iframe = .totalNumFrames
			elsif .iframe < 1
				.iframe = 1
			endif
			.nf = Get number of formants: .iframe		
		endwhile
		
		# New points
		if .th - .tl > 0.01
			selectObject: .textgrid
			.numPoints = Get number of points: .targetTier
			.tmp = 0
			if .numPoints > 0
				.tmp = Get time of point: .targetTier, .numPoints
			endif
			if .tl <> .tmp
				#Insert point: .targetTier, .tl, "L"
			else
				.ptxt$ = Get label of point: .targetTier, .numPoints
				#Set point text: .targetTier, .numPoints, .ptxt$+"L"
			endif
			#Insert point: .targetTier, .th, "H"
			
			selectObject: .formants
			if .tp > .tl and .tp < .th
				.tt = .tp
			else
				.tt = (.tl+.th)/2
				.f1_median = Get quantile: 1, .tl, .th, "Hertz", 0.5 
				.f2_median = Get quantile: 2, .tl, .th, "Hertz", 0.5 
				if .f1_median > 400
					.tt = Get time of maximum: 1, .tl, .th, "Hertz", "Parabolic"
				elsif .f2_median > 1600
					.tt = Get time of maximum: 2, .tl, .th, "Hertz", "Parabolic"
				elsif .f2_median < 1100
					.tt = Get time of minimum: 2, .tl, .th, "Hertz", "Parabolic"
				endif
				
				if .tt < .tl + 0.01 or .tt > .th - 0.01
					.tt = (.tl+.th)/2
				endif
			endif
			
			# Insert Target
			selectObject: .textgrid
			.numPoints = Get number of points: .targetTier
			.tmp = 0
			if .numPoints > 0
				.tmp = Get time of point: .targetTier, .numPoints
			endif
			if .tt <> .tmp
				Insert point: .targetTier, .tt, "T"
			endif
			
			# Now find vowel interval from taget
			.ttl = .tt
			# Lower end
			selectObject: .formants
			.f = Get value at time: 1, .ttl, "Hertz", "Linear"
			selectObject: .formantsBurg
			.b = Get bandwidth at time: 1, .ttl, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			.nf = Get number of formants: .iframe		
			while (.f > 300 and .f < 1000 and .b < 0.9 * .f and .nf >= 4) and .ttl - .dt >= .tl
				.ttl -= .dt
				selectObject: .formants
				.f = Get value at time: 1, .ttl, "Hertz", "Linear"
				selectObject: .formantsBurg
				.b = Get bandwidth at time: 1, .ttl, "Hertz", "Linear"
				.iframe = Get frame number from time: .ttl
				.nf = Get number of formants: .iframe		
			endwhile
			# Make sure something has changed
			if .ttl > .tt - 0.01
				.ttl = .tl
			endif
			
			# Higher end
			.tth = .tp
			selectObject: .formants
			.f = Get value at time: 1, .tth, "Hertz", "Linear"
			selectObject: .formantsBurg
			.b = Get bandwidth at time: 1, .tth, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			.nf = Get number of formants: .iframe		
			while (.f > 300 and .f < 1000 and .b < 0.9 * .f and .nf >= 4) and .tth + .dt <= .th
				.tth += .dt
				selectObject: .formants
				.f = Get value at time: 1, .tth, "Hertz", "Linear"
				selectObject: .formantsBurg
				.b = Get bandwidth at time: 1, .tth, "Hertz", "Linear"
				.iframe = Get frame number from time: .tth
				.nf = Get number of formants: .iframe		
			endwhile
			# Make sure something has changed
			if .tth < .tt + 0.01
				.tth = .th
			endif
			
			# Insert interval
			selectObject: .textgrid
			.index = Get interval at time: .vowelTier, .ttl
			.start = Get start time of interval: .vowelTier, .index
			.end = Get end time of interval: .vowelTier, .index
			if .ttl <> .start and .ttl <> .end
				Insert boundary: .vowelTier, .ttl
			endif
			.index = Get interval at time: .vowelTier, .tth
			.start = Get start time of interval: .vowelTier, .index
			.end = Get end time of interval: .vowelTier, .index
			if .tth <> .start and .tth <> .end
				Insert boundary: .vowelTier, .tth
			endif
			.index = Get interval at time: .vowelTier, .tt
			Set interval text: .vowelTier, .index, "Vowel"
			
		endif
	endfor
	selectObject: .formantsBurg
	Remove
	
endproc


###########################################################################
#                                                                         #
#  Praat Script Syllable Nuclei                                           #
#  Copyright (C) 2017  R.J.J.H. van Son                                   #
#                                                                         #
#    This program is free software: you can redistribute it and/or modify #
#    it under the terms of the GNU General Public License as published by #
#    the Free Software Foundation, either version 2 of the License, or    #
#    (at your option) any later version.                                  #
#                                                                         #
#    This program is distributed in the hope that it will be useful,      #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
#    GNU General Public License for more details.                         #
#                                                                         #
#    You should have received a copy of the GNU General Public License    #
#    along with this program.  If not, see http://www.gnu.org/licenses/   #
#                                                                         #
###########################################################################
#
# Simplified summary of the script by Nivja de Jong and Ton Wempe         #
procedure segment_syllables .silence_threshold .minimum_dip_between_peaks .minimum_pause_duration .keep_Soundfiles_and_Textgrids .soundid
	# Get intensity
	selectObject: .soundid
	.intensity = noprogress To Intensity: 70, 0, "yes"
	.dt = Get time step
	.maxFrame = Get number of frames
	
	# Determine Peaks
	selectObject: .intensity
	.peaksInt = noprogress To IntensityTier (peaks)
	.peaksPoint = Down to PointProcess
	.peaksPointTier = Up to TextTier: "P"
	Rename: "Peaks"
	
	# Determine valleys
	selectObject: .intensity
	.valleyInt = noprogress To IntensityTier (valleys)
	.valleyPoint = Down to PointProcess
	.valleyPointTier = Up to TextTier: "V"
	Rename: "Valleys"
	
	selectObject: .peaksPointTier, .valleyPointTier
	.segmentTextGrid = Into TextGrid
	
	selectObject: .peaksPointTier, .valleyPointTier, .peaksInt, .peaksPoint, .valleyInt, .valleyPoint
	Remove
	
	# Select the sounding part
	selectObject: .intensity
	.silenceTextGrid = noprogress To TextGrid (silences): .silence_threshold, .minimum_pause_duration, 0.05, "silent", "sounding"
	
	# Determine voiced parts
	selectObject: .soundid
	.voicePP = noprogress To PointProcess (periodic, cc): 75, 600
	.vuvTextGrid = noprogress To TextGrid (vuv): 0.02, 0.01
	plusObject: .segmentTextGrid, .silenceTextGrid
	.textgridid = Merge
	
	selectObject: .vuvTextGrid, .silenceTextGrid, .segmentTextGrid, .voicePP
	Remove
	
	# Remove irrelevant peaks and valleys
	selectObject: .textgridid
	.numPeaks = Get number of points: 1
	for .i to .numPeaks
		.t = Get time of point: 1, .numPeaks + 1 - .i
		.s = Get interval at time: 3, .t
		.soundLabel$ = Get label of interval: 3, .s
		.v = Get interval at time: 4, .t
		.voiceLabel$ = Get label of interval: 4, .v
		if .soundLabel$ = "silent" or .voiceLabel$ = "U"
			Remove point: 1, .numPeaks + 1 - .i
		endif
	endfor
	
	# valleys
	selectObject: .textgridid
	.numValleys = Get number of points: 2
	.numPeaks = Get number of points: 1
	# No peaks, nothing to do
	if .numPeaks <= 0
		goto VALLEYREADY
	endif
	
	for .i from 2 to .numValleys
		selectObject: .textgridid
		.il = .numValleys + 1 - .i
		.ih = .numValleys + 2 - .i
		.tl = Get time of point: 2, .il
		.th = Get time of point: 2, .ih
		
		
		.ph = Get high index from time: 1, .tl
		.tph = 0
		if .ph > 0 and .ph <= .numPeaks
			.tph = Get time of point: 1, .ph
		endif
		# If there is no peak between the valleys remove the highest
		if .tph <= 0 or (.tph < .tl or .tph > .th)
			# If the area is silent for both valleys, keep the one closest to a peak
			.psl = Get interval at time: 3, .tl
			.psh = Get interval at time: 3, .th
			.psl_label$ = Get label of interval: 3, .psl
			.psh_label$ = Get label of interval: 3, .psh
			if .psl_label$ = "silent" and .psh_label$ = "silent"
				.plclosest = Get nearest index from time: 1, .tl
				if .plclosest <= 0
					.plclosest = 1
				endif
				if .plclosest > .numPeaks
					.plclosest = .numPeaks
				endif
				.tlclosest = Get time of point: 1, .plclosest
				.phclosest = Get nearest index from time: 1, .th
				if .phclosest <= 0
					.phclosest = 1
				endif
				if .phclosest > .numPeaks
					.phclosest = .numPeaks
				endif
				.thclosest = Get time of point: 1, .phclosest
				if abs(.tlclosest - .tl) > abs(.thclosest - .th)
					selectObject: .textgridid
					Remove point: 2, .il
				else
					selectObject: .textgridid
					Remove point: 2, .ih
				endif
			else
				# Else Compare valley depths
				selectObject: .intensity
				.intlow = Get value at time: .tl, "Cubic"
				.inthigh = Get value at time: .th, "Cubic"
				if .inthigh >= .intlow
					selectObject: .textgridid
					Remove point: 2, .ih
				else
					selectObject: .textgridid
					Remove point: 2, .il
				endif
			endif
		endif
	endfor

	# Remove superfluous valleys
	selectObject: .textgridid
	.numValleys = Get number of points: 2
	.numPeaks = Get number of points: 1
	for .i from 1 to .numValleys
		selectObject: .textgridid
		.iv = .numValleys + 1 - .i
		.tv = Get time of point: 2, .iv
		.ph = Get high index from time: 1, .tv
		if .ph > .numPeaks
			.ph = .numPeaks
		endif
		.tph = Get time of point: 1, .ph
		.pl = Get low index from time: 1, .tv
		if .pl <= 0
			.pl = 1
		endif
		.tpl = Get time of point: 1, .pl
		
		# Get intensities
		selectObject: .intensity
		.v_int = Get value at time: .tv, "Cubic"
		.pl_int = Get value at time: .tpl, "Cubic"
		.ph_int = Get value at time: .tph, "Cubic"
		# If there is no real dip, remove valey and lowest peak
		if min((.pl_int - .v_int), (.ph_int - .v_int)) < .minimum_dip_between_peaks
			selectObject: .textgridid
			Remove point: 2, .iv
			if .ph <> .pl
				if .pl_int < .ph_int
					Remove point: 1, .pl
				else
					Remove point: 1, .ph
				endif
			endif
			.numPeaks = Get number of points: 1
			if .numPeaks <= 0
				goto VALLEYREADY
			endif
		endif
	endfor
	label VALLEYREADY
	
	selectObject: .intensity
	Remove
	
	selectObject: .textgridid
endproc

# 
# Determine COG as an intensity
#
# .cog_Matrix = Down to Matrix
# call calculateCOG .dt .soundid
# .cog_Tier = calculateCOG.cog_tier
# selectObject: .cog_Tier
# .numPoints = Get number of points
# for .i to .numPoints
# 	selectObject: .cog_Tier
# 	.cog = Get value at index: .i
# 	.t = Get time from index: .i
# 	selectObject: .intensity
# 	.c = Get frame number from time: .t
# 	if .c >= 0.5 and .c <= .maxFrame
# 		selectObject: .cog_Matrix
# 		Set value: 1, round(.c), .cog
# 	endif
# endfor
# selectObject: .cog_Matrix
# .cogIntensity = noprogress To Intensity

procedure calculateCOG .dt .sound
	selectObject: .sound
	.duration = Get total duration
	if .dt <= 0 or .dt > .sound
		.dt = 0.01
	endif
	
	# Create Spectrogram
	selectObject: .sound
	.spectrogram = noprogress To Spectrogram: 0.005, 8000, 0.002, 20, "Gaussian"
	.cog_tier = Create IntensityTier: "COG", 0.0, .duration
	
	.t = .dt / 2
	while .t < .duration
		selectObject: .spectrogram
		.spectrum = noprogress To Spectrum (slice): .t
		.cog_t = Get centre of gravity: 2
		selectObject: .cog_tier
		Add point: .t, .cog_t
		
		.t += .dt
		
		selectObject: .spectrum
		Remove
	endwhile
	
	selectObject: .spectrogram
	Remove
endproc
