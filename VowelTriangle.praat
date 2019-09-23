#! praat
# 
# Plot vowels into a vowel triangle
#
# We thank Xinyu Zhang for the Chinese translation (2019).
#
# Unless specified otherwise:
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.j.j.h.vanson@gmail.com, r.v.son@nki.nl
# 
#     VowelTriangle.praat: Praat script to practice vowel pronunciation 
#     
#     Copyright (C) 2017  R.J.J.H. van Son and the Netherlands Cancer Institute
# 
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
# 
#
# Initialization
# Get current Locale
uiLanguage$ = "EN"
.defaultLanguage = 1
.preferencesLanguageFile$ = preferencesDirectory$+"/VowelTriangle.prefs"
.preferencesLang$ = ""
.formant_default = 1
if fileReadable(.preferencesLanguageFile$)
	.preferences$ = readFile$(.preferencesLanguageFile$)
	if index(.preferences$, "Language=") > 0
		.preferencesLang$ = extractWord$(.preferences$, "Language=")
	else
		.preferencesLang$ = ""
	endif
	# Always assume that the preferences file could be corrupted
	if index(.preferences$, "Formant=") > 0
		.tmp$ = extractWord$(.preferences$, "Formant=")
		if index(.tmp$, "Burg")
			.formant_default = 2
		elsif index(.tmp$, "Robust")
			.formant_default = 3
		elsif index(.tmp$, "KeepAll")
			.formant_default = 4
		endif
	else
		.formant_default = 1
	endif
	
endif

.locale$ = "en"
if .preferencesLang$ <> ""
	.locale$ = .preferencesLang$
else
	if macintosh
		.scratch$ = replace_regex$(temporaryDirectory$+"/scratch"+date$()+".txt", "\W", "_", 0)
		runSystem_nocheck: "defaults read -g AppleLocale | cut -c 1-2 - > ",.scratch$
		.locale$ = readFile$(.scratch$)
		deleteFile: .scratch$
	elsif unix
		.locale$ = environment$("LANG")
	elsif windows
		.scratch$ = replace_regex$(temporaryDirectory$+"/scratch"+date$()+".txt", "\W", "_", 0)
		runSystem_nocheck: "dism /online /get-intl > ",.scratch$
		.locale$ = readFile$(.scratch$)
		.locale$ = replace_regex$(.locale$, "\n", " ", 0)	
		.locale$ = replace_regex$(.locale$, "^.*Default System UI language : (\S+).*", "\1", 0)
		deleteFile: .scratch$	
	endif
	.locale$ = replace_regex$(.preferencesLang$, "(.)", "\U\1", 0)
endif

# Always assume that the preferences file could be corrupted
if startsWith(.locale$, "EN")
	uiLanguage$ = "EN"
	.defaultLanguage = 1
elsif startsWith(.locale$, "NL")
	uiLanguage$ = "NL"
	.defaultLanguage = 2
elsif startsWith(.locale$, "DE")
	uiLanguage$ = "DE"
	.defaultLanguage = 3
elsif startsWith(.locale$, "FR")
	uiLanguage$ = "FR"
	.defaultLanguage = 4
elsif startsWith(.locale$, "ZH")
	uiLanguage$ = "ZH"
	.defaultLanguage = 5
elsif startsWith(.locale$, "ES")
	uiLanguage$ = "ES"
	.defaultLanguage = 6
elsif startsWith(.locale$, "PT")
	uiLanguage$ = "PT"
	.defaultLanguage = 7
elsif startsWith(.locale$, "IT")
	uiLanguage$ = "IT"
	.defaultLanguage = 8
#elsif startsWith(.locale$, "MYLANGUAGE")
#	uiLanguage$ = "XX"
#	.defaultLanguage = 9
endif

.sp_default = 1
output_table$ = ""
vtl_normalization = 0

default_Dot_Radius = 0.01
dot_Radius_Cutoff = 300
# 
#######################################################################
# 
# Enter valid file path in input_file$ to run non-interactive
#
#input_file$ = "concatlist.tsv"
#input_file$ = "chunkslist.tsv"
input_file$ = ""

input_table = -1
.continue = 1
#
# The input table should have tab separated columns labeled: 
# Title, Speaker, File, Language, Log, Plotfile
# An example would be a tab separated list:
# F40L2VT2 F IFAcorpus/chunks/F40L/F40L2VT1.aifc NL target/results.tsv target/F40L2VT2.png
# All files are used AS IS, and nothing is drawn unless a "Plotfile" is entered
#
if input_file$ <> "" and fileReadable(input_file$) and index_regex(input_file$, "(?i\.(tsv|Table))")
	input_table = Read Table from tab-separated file: input_file$
	.numRows = Get number of rows
	.i = Get column index: "Log"
	if .i <= 0
		Append column: "Log"
		for .r to .numRows
			Set string value: .r, "Log", "-"
		endfor
	endif 
	.i = Get column index: "Plotfile"
	if .i <= 0
		Append column: "Plotfile"
		for .r to .numRows
			Set string value: .r, "Plotfile", "-"
		endfor
	endif 
endif

# When using a microphone:
.input$ = "Microphone"
.samplingFrequency = 44100
.recordingTime = 4

# Define Language
# Add new targets if necessary

# Select algorithm for calculating formants
# Alternatives: "SL", "Burg", "Robust", or "KeepAll"

# Vowel targets
targetFormantAlgorithm$ = "Robust"

# Plotting can be different from the target, in principle
plotFormantAlgorithm$ = targetFormantAlgorithm$

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
uiMessage$ ["EN", "Record1"] = "Record the ##continuous speech#"
uiMessage$ ["EN", "Record2"] = "Please be ready to start"
uiMessage$ ["EN", "Record3"] = "Select the speech you want to analyse"
uiMessage$ ["EN", "Open1"] = "Open the recording containing the speech"
uiMessage$ ["EN", "Open2"] = "Select the speech you want to analyse"
uiMessage$ ["EN", "Corneri"] = "h##ea#t"
uiMessage$ ["EN", "Corneru"] = "h##oo#t"
uiMessage$ ["EN", "Cornera"] = "h##a#t"
uiMessage$ ["EN", "DistanceTitle"] = "Rel. Distance (N)"
uiMessage$ ["EN", "AreaTitle"] = "Rel. Area"
uiMessage$ ["EN", "Area1"] = "1"
uiMessage$ ["EN", "Area2"] = "2"
uiMessage$ ["EN", "AreaN"] = "N"
uiMessage$ ["EN", "VTL"] = "Vocal tract"

uiMessage$ ["EN", "LogFile"] = "Write log to table (""-"" write to the info window)"
uiMessage$ ["EN", "CommentContinue"] = "Click on ""Continue"" if you want to analyze more speech samples"
uiMessage$ ["EN", "CommentOpen"] = "Click on ""Open"" and select a recording"
uiMessage$ ["EN", "CommentRecord"] = "Click on ""Record"" and start speaking"
uiMessage$ ["EN", "CommentList"] = "Record sound, ""Save to list & Close"", then click ""Continue"""
uiMessage$ ["EN", "SavePicture"] = "Save picture"
uiMessage$ ["EN", "DoContinue"] = "Do you want to continue?"
uiMessage$ ["EN", "SelectSound1"] = "Select the sound and continue"
uiMessage$ ["EN", "SelectSound2"] = "It is possible to remove unwanted sounds from the selection"
uiMessage$ ["EN", "SelectSound3"] = "Select the unwanted part and then choose ""Cut"" from the ""Edit"" menu"
uiMessage$ ["EN", "Stopped"] = "Vowel Triangle stopped"
uiMessage$ ["EN", "ErrorSound"] = "Error: Not a sound "
uiMessage$ ["EN", "Nothing to do"] = "Nothing to do"
uiMessage$ ["EN", "No readable recording selected "] = "No readable recording selected "

uiMessage$ ["EN", "Interface Language"] = "Language"
uiMessage$ ["EN", "Speaker is a"] = "Speaker is a"
uiMessage$ ["EN", "Male"] = "Male ♂"
uiMessage$ ["EN", "Female"] = "Female ♀"
uiMessage$ ["EN", "Automatic"] = "Automatic"
uiMessage$ ["EN", "Experimental"] = "Experimental: Select formant tracking method"
uiMessage$ ["EN", "Continue"] = "Continue"
uiMessage$ ["EN", "Done"] = "Done"
uiMessage$ ["EN", "Stop"] = "Stop"
uiMessage$ ["EN", "Open"] = "Open"
uiMessage$ ["EN", "Record"] = "Record"
uiMessage$ ["EN", "untitled"] = "untitled"
uiMessage$ ["EN", "Title"] 			= "Title"

# Dutch
uiMessage$ ["NL", "PauseRecord"] 	= "Neem lopende spraak op"
uiMessage$ ["NL", "Record1"] 		= "Neem de ##lopende spraak# op"
uiMessage$ ["NL", "Record2"] 		= "Zorg dat u klaar ben om te spreken"
uiMessage$ ["NL", "Record3"] 		= "Selecteer de spraak die u wilt analyseren"
uiMessage$ ["NL", "Open1"] 			= "Open de spraakopname"
uiMessage$ ["NL", "Open2"] 			= "Selecteer de spraak die u wilt analyseren"
uiMessage$ ["NL", "Corneri"] 		= "h##ie#t"
uiMessage$ ["NL", "Corneru"] 		= "h##oe#d"
uiMessage$ ["NL", "Cornera"] 		= "h##aa#t"
uiMessage$ ["NL", "DistanceTitle"] 	= "Rel. Afstand (N)"
uiMessage$ ["NL", "AreaTitle"] 		= "Rel. Oppervlak"
uiMessage$ ["NL", "Area1"] 			= "1"
uiMessage$ ["NL", "Area2"] 			= "2"
uiMessage$ ["NL", "AreaN"] 			= "N"
uiMessage$ ["NL", "VTL"] 			= "Spraakkanaal"

uiMessage$ ["NL", "LogFile"] 		= "Schrijf resultaten naar log bestand (""-"" schrijft naar info venster)"
uiMessage$ ["NL", "CommentContinue"] = "Klik op ""Doorgaan"" als u meer spraakopnamen wilt analyseren"
uiMessage$ ["NL", "CommentOpen"] 	= "Klik op ""Open"" en selecteer een opname"
uiMessage$ ["NL", "CommentRecord"] 	= "Klik op ""Opnemen"" en start met spreken"
uiMessage$ ["NL", "CommentList"] 	= "Spraak opnemen, ""Save to list & Close"", daarna klik op ""Doorgaan"""
uiMessage$ ["NL", "SavePicture"] 	= "Bewaar afbeelding"
uiMessage$ ["NL", "DoContinue"] 	= "Wilt u doorgaan?"
uiMessage$ ["NL", "SelectSound1"] 	= "Selecteer het spraakfragment en ga door"
uiMessage$ ["NL", "SelectSound2"] 	= "Het is mogelijk om ongewenste geluiden uit de opname te verwijderen"
uiMessage$ ["NL", "SelectSound3"] 	= "Selecteer het ongewenste deel en kies ""Cut"" in het ""Edit"" menu"
uiMessage$ ["NL", "Stopped"] 		= "Vowel Triangle is gestopt"
uiMessage$ ["NL", "ErrorSound"] 	= "Fout: Dit is geen geluid "
uiMessage$ ["NL", "Nothing to do"] 	= "Geen taken"
uiMessage$ ["NL", "No readable recording selected "] = "Geen leesbare opname geselecteerd "

uiMessage$ ["NL", "Interface Language"] = "Taal (Language)"
uiMessage$ ["NL", "Speaker is a"] 	= "De Spreker is een"
uiMessage$ ["NL", "Male"] 			= "Man ♂"
uiMessage$ ["NL", "Female"] 		= "Vrouw ♀"
uiMessage$ ["NL", "Automatic"] 		= "Automatisch"
uiMessage$ ["NL", "Experimental"] 	= "Experimenteel: Kies methode om formanten te berekenen"
uiMessage$ ["NL", "Continue"] 		= "Doorgaan"
uiMessage$ ["NL", "Done"] 			= "Klaar"
uiMessage$ ["NL", "Stop"] 			= "Stop"
uiMessage$ ["NL", "Open"] 			= "Open"
uiMessage$ ["NL", "Record"] 		= "Opnemen"
uiMessage$ ["NL", "untitled"] 		= "zonder titel"
uiMessage$ ["NL", "Title"] 			= "Titel"

# German
uiMessage$ ["DE", "PauseRecord"] 	= "Zeichne laufende Sprache auf"
uiMessage$ ["DE", "Record1"] 		= "Die ##laufende Sprache# aufzeichnen"
uiMessage$ ["DE", "Record2"] 		= "Bitte seien Sie bereit zu sprechen"
uiMessage$ ["DE", "Record3"] 		= "Wählen Sie die Sprachaufnahme, die Sie analysieren möchten"
uiMessage$ ["DE", "Open1"] 			= "Öffnen Sie die Sprachaufnahme"
uiMessage$ ["DE", "Open2"] 			= "Wählen Sie die Sprachaufnahme, die Sie analysieren möchten"
uiMessage$ ["DE", "Corneri"] 		= "L##ie#d"
uiMessage$ ["DE", "Corneru"] 		= "H##u#t"
uiMessage$ ["DE", "Cornera"] 		= "T##a#l"
uiMessage$ ["DE", "DistanceTitle"] 	= "Rel. Länge (N)"
uiMessage$ ["DE", "AreaTitle"] 		= "Rel. Oberfläche"
uiMessage$ ["DE", "Area1"] 			= "1"
uiMessage$ ["DE", "Area2"] 			= "2"
uiMessage$ ["DE", "AreaN"] 			= "N"
uiMessage$ ["DE", "VTL"] 			= "Vokaltrakt"
                                     
uiMessage$ ["DE", "LogFile"] 		= "Daten in Tabelle schreiben (""-"" in das Informationsfenster schreiben)"
uiMessage$ ["DE", "CommentContinue"]= "Klicken Sie auf ""Weiter"", wenn Sie mehr Sprachproben analysieren möchten"
uiMessage$ ["DE", "CommentOpen"] 	= "Klicke auf ""Öffnen"" und wähle eine Aufnahme"
uiMessage$ ["DE", "CommentRecord"] 	= "Klicke auf ""Aufzeichnen"" und sprich"
uiMessage$ ["DE", "CommentList"] 	= "Sprache aufnehmen, ""Save to list & Close"", dann klicken Sie auf ""Weitergehen"""
uiMessage$ ["DE", "SavePicture"] 	= "Bild speichern"
uiMessage$ ["DE", "DoContinue"] 	= "Möchten Sie weitergehen?"
uiMessage$ ["DE", "SelectSound1"] 	= "Wählen Sie den Aufnahmebereich und gehen Sie weiter"
uiMessage$ ["DE", "SelectSound2"] 	= "Es ist möglich, unerwünschte Geräusche aus der Auswahl zu entfernen"
uiMessage$ ["DE", "SelectSound3"] 	= "Wählen Sie den unerwünschten Teil und wählen Sie dann ""Cut"" aus dem ""Edit"" Menü"
uiMessage$ ["DE", "Stopped"] 		= "VowelTriangle ist gestoppt"
uiMessage$ ["DE", "ErrorSound"] 	= "Fehler: Keine Sprache gefunden"
uiMessage$ ["DE", "Nothing to do"] 	= "Keine Aufgaben"
uiMessage$ ["DE", "No readable recording selected "] = "Keine verwertbare Aufnahme ausgewählt "
               
uiMessage$ ["DE", "Interface Language"] = "Sprache (Language)"
uiMessage$ ["DE", "Speaker is a"] 	= "Der Sprecher ist ein(e)"
uiMessage$ ["DE", "Male"] 			= "Man ♂"
uiMessage$ ["DE", "Female"] 		= "Frau ♀"
uiMessage$ ["DE", "Automatic"] 		= "Selbstauswahl"
uiMessage$ ["DE", "Experimental"] 	= "Experimentell: Wählen Sie die Formant-Berechnungsmethode"
uiMessage$ ["DE", "Continue"] 		= "Weitergehen"
uiMessage$ ["DE", "Done"] 			= "Fertig"
uiMessage$ ["DE", "Stop"] 			= "Halt"
uiMessage$ ["DE", "Open"] 			= "Öffnen"
uiMessage$ ["DE", "Record"] 		= "Aufzeichnen"
uiMessage$ ["DE", "untitled"] 		= "ohne Titel"
uiMessage$ ["DE", "Title"] 			= "Titel"

# French
uiMessage$ ["FR", "PauseRecord"]	= "Enregistrer un discours continu"
uiMessage$ ["FR", "Record1"]		= "Enregistrer le ##discours continu#"
uiMessage$ ["FR", "Record2"]		= "S'il vous plaît soyez prêt à commencer"
uiMessage$ ["FR", "Record3"]		= "Sélectionnez le discours que vous voulez analyser"
uiMessage$ ["FR", "Open1"]			= "Ouvrir l'enregistrement contenant le discours"
uiMessage$ ["FR", "Open2"]			= "Sélectionnez le discours que vous voulez analyser"
uiMessage$ ["FR", "Corneri"]		= "s##i#"
uiMessage$ ["FR", "Corneru"]		= "f##ou#"
uiMessage$ ["FR", "Cornera"]		= "l##à#"
uiMessage$ ["FR", "DistanceTitle"]	= "Longeur Relative (N)"
uiMessage$ ["FR", "AreaTitle"]		= "Surface Relative"
uiMessage$ ["FR", "Area1"]			= "1"
uiMessage$ ["FR", "Area2"]			= "2"
uiMessage$ ["FR", "AreaN"]			= "N"
uiMessage$ ["FR", "VTL"] 			= "Conduit vocal"
                                     
uiMessage$ ["FR", "LogFile"]		= "Écrire un fichier journal dans une table (""-"" écrire dans la fenêtre d'information)"
uiMessage$ ["FR", "CommentContinue"]= "Cliquez sur ""Continuer"" si vous voulez analyser plus d'échantillons de discours"
uiMessage$ ["FR", "CommentOpen"]	= "Cliquez sur ""Ouvrir"" et sélectionnez un enregistrement"
uiMessage$ ["FR", "CommentRecord"]	= "Cliquez sur ""Enregistrer"" et commencez à parler"
uiMessage$ ["FR", "CommentList"]	= "Enregistrer le son, ""Save to list & Close"", puis cliquez sur ""Continuer"""
uiMessage$ ["FR", "SavePicture"]	= "Enregistrer l'image"
uiMessage$ ["FR", "DoContinue"]		= "Voulez-vous continuer?"
uiMessage$ ["FR", "SelectSound1"]	= "Sélectionnez le son et continuez"
uiMessage$ ["FR", "SelectSound2"]	= "Il est possible de supprimer les sons indésirables de la sélection"
uiMessage$ ["FR", "SelectSound3"]	= "Sélectionnez la partie indésirable, puis choisissez ""Cut"" dans le menu ""Edit"""
uiMessage$ ["FR", "Stopped"]		= "VowelTriangle s'est arrêté"
uiMessage$ ["FR", "ErrorSound"]		= "Erreur: pas du son"
uiMessage$ ["FR", "Nothing to do"] 	= "Rien à faire"
uiMessage$ ["FR", "No readable recording selected "] = "Aucun enregistrement utilisable sélectionné "
                  
uiMessage$ ["FR", "Interface Language"] = "Langue (Language)"
uiMessage$ ["FR", "Speaker is a"]	= "Le locuteur est un(e)"
uiMessage$ ["FR", "Male"] 			= "Homme ♂"
uiMessage$ ["FR", "Female"] 		= "Femme ♀"
uiMessage$ ["FR", "Automatic"] 		= "Auto-sélection"
uiMessage$ ["FR", "Experimental"] 	= "Expérimental: Sélectionner la méthode de calcul du formant"
uiMessage$ ["FR", "Continue"]		= "Continuer"
uiMessage$ ["FR", "Done"]			= "Terminé"
uiMessage$ ["FR", "Stop"]			= "Arrêt"
uiMessage$ ["FR", "Open"]			= "Ouvert"
uiMessage$ ["FR", "Record"]			= "Enregistrer"
uiMessage$ ["FR", "untitled"] 		= "sans titre"
uiMessage$ ["FR", "Title"] 			= "Titre"

# Chinese
uiMessage$ ["ZH", "PauseRecord"] 	= "录制连续语音"
uiMessage$ ["ZH", "Record1"] 		= "录制##连续语音#"
uiMessage$ ["ZH", "Record2"] 		= "请准备好开始"
uiMessage$ ["ZH", "Record3"] 		= "选择你想要分析的语音"
uiMessage$ ["ZH", "Open1"] 			= "打开包含语音的录音文件"
uiMessage$ ["ZH", "Open2"] 			= "选择你想要分析的语音片段"
uiMessage$ ["ZH", "Corneri"] 		= "必"
uiMessage$ ["ZH", "Corneru"] 		= "不"
uiMessage$ ["ZH", "Cornera"] 		= "巴"
uiMessage$ ["ZH", "DistanceTitle"] 	= "相对长度 (N)"
uiMessage$ ["ZH", "AreaTitle"] 		= "相对面积"
uiMessage$ ["ZH", "Area1"] 			= "1"
uiMessage$ ["ZH", "Area2"] 			= "2"
uiMessage$ ["ZH", "AreaN"] 			= "N"
uiMessage$ ["ZH", "VTL"] 			= "声道"


uiMessage$ ["ZH", "LogFile"] 		= "将日志写入表格 (""-"" 写入信息窗口)"
uiMessage$ ["ZH", "CommentContinue"] = "点击 ""继续"" 如果你想分析更多的语音样本"
uiMessage$ ["ZH", "CommentOpen"] 	= "点击 ""打开录音"" 并选择一个录音"
uiMessage$ ["ZH", "CommentRecord"] 	= "点击 ""录音"" 并开始讲话"
uiMessage$ ["ZH", "CommentList"] 	= "录制声音, ""Save to list & Close"", 然后单击 ""继续"""
uiMessage$ ["ZH", "SavePicture"] 	= "保存图片"
uiMessage$ ["ZH", "DoContinue"] 	= "你想继续吗"
uiMessage$ ["ZH", "SelectSound1"] 	= "选择声音并继续"
uiMessage$ ["ZH", "SelectSound2"] 	= "可以从选择中删除不需要的声音"
uiMessage$ ["ZH", "SelectSound3"] 	= "选择不需要的部分，然后从 ""Edit"" 菜单选择 ""Cut"""
uiMessage$ ["ZH", "Stopped"] 		= "VowelTriangle 已停止运行"
uiMessage$ ["ZH", "ErrorSound"] 	= "错误：不是声音"
uiMessage$ ["ZH", "Nothing to do"] 	= "无法进行"
uiMessage$ ["ZH", "No readable recording selected "] = "未选择可读取的录音 "

uiMessage$ ["ZH", "Interface Language"] = "语言 (Language)"
uiMessage$ ["ZH", "Speaker is a"]	= "演讲者是"
uiMessage$ ["ZH", "Male"] 			= "男性 ♂"
uiMessage$ ["ZH", "Female"] 		= "女性 ♀"
uiMessage$ ["ZH", "Automatic"] 		= "自动选择"
uiMessage$ ["ZH", "Experimental"] 	= "试验：选择共振峰值测量方式"
uiMessage$ ["ZH", "Continue"] 		= "继续"
uiMessage$ ["ZH", "Done"] 			= "完成"
uiMessage$ ["ZH", "Stop"] 			= "结束"
uiMessage$ ["ZH", "Open"] 			= "从文件夹打开"
uiMessage$ ["ZH", "Record"] 		= "录音"
uiMessage$ ["ZH", "untitled"] 		= "无标题"
uiMessage$ ["ZH", "Title"] 			= "标题"

# Spanish
uiMessage$ ["ES", "PauseRecord"]	= "Grabar un discurso continuo"
uiMessage$ ["ES", "Record1"]		= "Guardar ##discurso continuo#"
uiMessage$ ["ES", "Record2"]		= "Por favor, prepárate para comenzar"
uiMessage$ ["ES", "Record3"]		= "Seleccione el discurso que quiere analizar"
uiMessage$ ["ES", "Open1"]			= "Abre la grabación que contiene el discurso"
uiMessage$ ["ES", "Open2"]			= "Seleccione el discurso que quiere analizar"
uiMessage$ ["ES", "Corneri"]		= "s##i#"
uiMessage$ ["ES", "Corneru"]		= "##u#so"
uiMessage$ ["ES", "Cornera"]		= "h##a#"
uiMessage$ ["ES", "DistanceTitle"]	= "Longitud relativa (N)"
uiMessage$ ["ES", "AreaTitle"]		= "Superficie relativa"
uiMessage$ ["ES", "Area1"]			= "1"
uiMessage$ ["ES", "Area2"]			= "2"
uiMessage$ ["ES", "AreaN"]			= "N"
uiMessage$ ["ES", "VTL"] 			= "Tracto vocal"
                                      
uiMessage$ ["ES", "LogFile"]		= "Escribir un archivo de registro en una tabla (""-"" escribir en la ventana de información)"
uiMessage$ ["ES", "CommentContinue"]= "Haga clic en ""Continúa"" si desea analizar más muestras de voz"
uiMessage$ ["ES", "CommentOpen"]	= "Haga clic en ""Abrir"" y seleccione un registro"
uiMessage$ ["ES", "CommentRecord"]	= "Haz clic en ""Grabar"" y comienza a hablar"
uiMessage$ ["ES", "CommentList"]	= "Grabar sonido, ""Save to list & Close"", luego haga clic en ""Continúa"""
uiMessage$ ["ES", "SavePicture"]	= "Guardar imagen"
uiMessage$ ["ES", "DoContinue"]		= "¿Quieres continuar?"
uiMessage$ ["ES", "SelectSound1"]	= "Selecciona el sonido y continúa"
uiMessage$ ["ES", "SelectSound2"]	= "Es posible eliminar sonidos no deseados de la selección"
uiMessage$ ["ES", "SelectSound3"]	= "Seleccione la parte no deseada, luego elija ""Cut"" desde el menú ""Edit"""
uiMessage$ ["ES", "Stopped"]		= "VowelTriangle se ha detenido"
uiMessage$ ["ES", "ErrorSound"]		= "Error: no hay sonido"
uiMessage$ ["ES", "Nothing to do"] 	= "Nada que hacer"
uiMessage$ ["ES", "No readable recording selected "] = "No se ha seleccionado ningún registro utilizable "

uiMessage$ ["ES", "Interface Language"] = "Idioma (Language)"
uiMessage$ ["ES", "Speaker is a"]	= "El hablante es un(a)"
uiMessage$ ["ES", "Male"] 			= "Hombre ♂"
uiMessage$ ["ES", "Female"] 		= "Mujer ♀"
uiMessage$ ["ES", "Automatic"] 		= "Autoselección"
uiMessage$ ["ES", "Experimental"] 	= "Experimental: seleccione el método de seguimiento de formantes"
uiMessage$ ["ES", "Continue"]		= "Continúa"
uiMessage$ ["ES", "Done"]			= "Terminado"
uiMessage$ ["ES", "Stop"]			= "Detener"
uiMessage$ ["ES", "Open"]			= "Abrir"
uiMessage$ ["ES", "Record"]			= "Grabar"
uiMessage$ ["ES", "untitled"] 		= "no tiene título"
uiMessage$ ["ES", "Title"] 			= "Título"

# Portugese
uiMessage$ ["PT", "PauseRecord"]	= "Gravar um discurso contínuo"
uiMessage$ ["PT", "Record1"]		= "Salvar ##discurso contínua#"
uiMessage$ ["PT", "Record2"]		= "Por favor, prepare-se para começar"
uiMessage$ ["PT", "Record3"]		= "Selecione o discurso que deseja analisar"
uiMessage$ ["PT", "Open1"]			= "Abra a gravação que contém o discurso"
uiMessage$ ["PT", "Open2"]			= "Selecione o discurso que deseja analisar"
uiMessage$ ["PT", "Corneri"]		= "s##i#"
uiMessage$ ["PT", "Corneru"]		= "r##u#a"
uiMessage$ ["PT", "Cornera"]		= "d##á#"
uiMessage$ ["PT", "DistanceTitle"]	= "Comprimento relativo (N)"
uiMessage$ ["PT", "AreaTitle"]		= "Superfície relativa"
uiMessage$ ["PT", "Area1"]			= "1"
uiMessage$ ["PT", "Area2"]			= "2"
uiMessage$ ["PT", "AreaN"]			= "N"
uiMessage$ ["PT", "VTL"] 			= "Trato vocal"
                                                                            
uiMessage$ ["PT", "LogFile"]		= "Escreva um arquivo de registro em uma tabela (""-"" escreva na janela de informações)"
uiMessage$ ["PT", "CommentContinue"]= "Clique em ""Continuar"" se quiser analisar mais amostras de voz"
uiMessage$ ["PT", "CommentOpen"]	= "Clique em ""Abrir"" e selecione um registro"
uiMessage$ ["PT", "CommentRecord"]	= "Clique ""Gravar"" e comece a falar "
uiMessage$ ["PT", "CommentList"]	= "Gravar som, ""Save to list & Close"", depois clique em ""Continuar"""
uiMessage$ ["PT", "SavePicture"]	= "Salvar imagem"
uiMessage$ ["PT", "DoContinue"]		= "Você quer continuar?"
uiMessage$ ["PT", "SelectSound1"]	= "Selecione o som e continue"
uiMessage$ ["PT", "SelectSound2"]	= "É possível remover sons indesejados da seleção"
uiMessage$ ["PT", "SelectSound3"]	= "Selecione a parte indesejada, então escolha ""Cut"" no menu ""Edit"""
uiMessage$ ["PT", "Stopped"]		= "VowelTriangle parou"
uiMessage$ ["PT", "ErrorSound"]		= "Erro: não há som"
uiMessage$ ["PT", "Nothing to do"] 	= "Nada para fazer"
uiMessage$ ["PT", "No readable recording selected "] = "Nenhum registro utilizável foi selecionado"

uiMessage$ ["PT", "Interface Language"] = "Idioma (Language)"
uiMessage$ ["PT", "Speaker is a"]	= "O falante é um(a)"
uiMessage$ ["PT", "Male"] 			= "Homem ♂"
uiMessage$ ["PT", "Female"] 		= "Mulher ♀"
uiMessage$ ["PT", "Automatic"] 		= "Auto-seleção"
uiMessage$ ["PT", "Experimental"] 	= "Experimental: Selecione o método de rastreamento formant"
uiMessage$ ["PT", "Continue"]		= "Continuar"
uiMessage$ ["PT", "Done"]			= "Terminado"
uiMessage$ ["PT", "Stop"]			= "Pare"
uiMessage$ ["PT", "Open"]			= "Abrir"
uiMessage$ ["PT", "Record"]			= "Gravar"
uiMessage$ ["PT", "untitled"] 		= "sem título"
uiMessage$ ["PT", "Title"] 			= "Título"

# Italian
uiMessage$ ["IT", "PauseRecord"]	= "Registra un discorso continuo"
uiMessage$ ["IT", "Record1"]		= "Salva ##discorso continuo#"
uiMessage$ ["IT", "Record2"]		= "Per favore, preparati a iniziare"
uiMessage$ ["IT", "Record3"]		= "Seleziona il discorso che vuoi analizzare"
uiMessage$ ["IT", "Open1"]			= "Apri la registrazione che contiene il discorso"
uiMessage$ ["IT", "Open2"]			= "Seleziona il discorso che vuoi analizzare"
uiMessage$ ["IT", "Corneri"]		= "s##ì#"
uiMessage$ ["IT", "Corneru"]		= "##u#si"
uiMessage$ ["IT", "Cornera"]		= "sar##à#"
uiMessage$ ["IT", "DistanceTitle"]	= "Lunghezza relativa (N)"
uiMessage$ ["IT", "AreaTitle"]		= "Superficie relativa"
uiMessage$ ["IT", "Area1"]			= "1"
uiMessage$ ["IT", "Area2"]			= "2"
uiMessage$ ["IT", "AreaN"]			= "N"
uiMessage$ ["IT", "VTL"] 			= "Tratto vocale"
                                                                            
uiMessage$ ["IT", "LogFile"]		= "Scrivi un file di registrazione in una tabella (""-"" scrivi nella finestra delle informazioni)"
uiMessage$ ["IT", "CommentContinue"]= "Clicca su ""Continua"" se vuoi analizzare più campioni vocali"
uiMessage$ ["IT", "CommentOpen"]	= "Fare clic su ""Apri"" e selezionare un record"
uiMessage$ ["IT", "CommentRecord"]	= "Fai clic su ""Registra"" e inizia a parlare"
uiMessage$ ["IT", "CommentList"]	= "Registra suono, ""Save to list & Close"", quindi fai clic su ""Continua"""
uiMessage$ ["IT", "SavePicture"]	= "Salva immagine"
uiMessage$ ["IT", "DoContinue"]		= "Vuoi continuare?"
uiMessage$ ["IT", "SelectSound1"]	= "Seleziona il suono e continua"
uiMessage$ ["IT", "SelectSound2"]	= "È possibile rimuovere i suoni indesiderati dalla selezione"
uiMessage$ ["IT", "SelectSound3"]	= "Seleziona la parte indesiderata, quindi scegli ""Cut"" dal menu ""Edit"""
uiMessage$ ["IT", "Stopped"]		= "VowelTriangle si è fermato"
uiMessage$ ["IT", "ErrorSound"]		= "Errore: non c'è suono"
uiMessage$ ["IT", "Nothing to do"] 	= "Niente da fare"
uiMessage$ ["IT", "No readable recording selected "] = "Nessun record utilizzabile è stato selezionato "

uiMessage$ ["IT", "Interface Language"] = "Lingua (Language)"
uiMessage$ ["IT", "Speaker is a"]	= "L‘oratore è un(a)"
uiMessage$ ["IT", "Male"] 			= "Uomo ♂"
uiMessage$ ["IT", "Female"] 		= "Donna ♀"
uiMessage$ ["IT", "Automatic"] 		= "Auto-selezione"
uiMessage$ ["IT", "Experimental"] 	= "Sperimentale: seleziona il metodo di tracciamento dei formanti"
uiMessage$ ["IT", "Continue"]		= "Continua"
uiMessage$ ["IT", "Done"]			= "Finito"
uiMessage$ ["IT", "Stop"]			= "Fermare"
uiMessage$ ["IT", "Open"]			= "Apri"
uiMessage$ ["IT", "Record"]			= "Registra"
uiMessage$ ["IT", "untitled"] 		= "senza titolo"
uiMessage$ ["IT", "Title"] 			= "Titolo"

#############################################################
#
# To add a new interface language, translate the text below
# and substitute in the correct places. Keep the double quotes "" intact
# Replace the "EN" in the ''uiMessage$ ["EN",'' to the code you
# need. Then add the new language in the options (following "English" etc.)
# and the code following the endPause below.
#
# "Record continuous speech"
# "Record the ##continuous speech#"
# "Please be ready to start"
# "Select the speech you want to analyse"
# "Open the recording containing the speech"
# "Select the speech you want to analyse"
# "h##ea#t"
# "h##oo#t"
# "h##a#t"
# "Rel. Distance (N)"
# "Rel. Area"
# "1"
# "2"
# "N"

# "Write log to table (""-"" write to the info window)"
# "Click on ""Continue"" if you want to analyze more speech samples"
# "Click on ""Open"" and select a recording"
# "Click on ""Record"" and start speaking"
# "Record sound, ""Save to list & Close"", then click ""Continue"""
# "Save picture"
# "Do you want to continue?"
# "Select the sound and continue"
# "It is possible to remove unwanted sounds from the selection"
# "Select the unwanted part and then chose ""Cut"" from the ""Edit"" menu"
# "Vowel Triangle stopped"
# "Error: Not a sound "
# "Nothing to do"
# "No readable recording selected "

# "Language"
# "Speaker is a"
# "Male"
# "Female"
# "Continue"
# "Done"
# "Stop"
# "Open"
# "Record"
#
##############################################################


# Formant values according to 
# IFA corpus averages from FPA isolated vowels

###############################################
#
# Split-Levinson (SL)
#
###############################################

# Male 
phonemes ["SL", "M", "A", "F1"] = 696
phonemes ["SL", "M", "A", "F2"] = 1066
phonemes ["SL", "M", "E", "F1"] = 552
phonemes ["SL", "M", "E", "F2"] = 1659
phonemes ["SL", "M", "I", "F1"] = 378
phonemes ["SL", "M", "I", "F2"] = 1869
phonemes ["SL", "M", "O", "F1"] = 483
phonemes ["SL", "M", "O", "F2"] = 726
phonemes ["SL", "M", "Y", "F1"] = 418
phonemes ["SL", "M", "Y", "F2"] = 1455
phonemes ["SL", "M", "Y:", "F1"] = 386
phonemes ["SL", "M", "Y:", "F2"] = 1492
phonemes ["SL", "M", "a", "F1"] = 789
phonemes ["SL", "M", "a", "F2"] = 1291
phonemes ["SL", "M", "au", "F1"] = 584
phonemes ["SL", "M", "au", "F2"] = 959
phonemes ["SL", "M", "e", "F1"] = 372
phonemes ["SL", "M", "e", "F2"] = 1960
phonemes ["SL", "M", "ei", "F1"] = 500
phonemes ["SL", "M", "ei", "F2"] = 1733
phonemes ["SL", "M", "i", "F1"] = 260
phonemes ["SL", "M", "i", "F2"] = 1972
phonemes ["SL", "M", "o", "F1"] = 427
phonemes ["SL", "M", "o", "F2"] = 744
phonemes ["SL", "M", "u", "F1"] = 288
phonemes ["SL", "M", "u", "F2"] = 666
phonemes ["SL", "M", "ui", "F1"] = 495
phonemes ["SL", "M", "ui", "F2"] = 1469
phonemes ["SL", "M", "y", "F1"] = 268
phonemes ["SL", "M", "y", "F2"] = 1581
# Guessed
phonemes ["SL", "M", "@", "F1"] = 417.7000
phonemes ["SL", "M", "@", "F2"] = 1455.100

# Female 
phonemes ["SL", "F", "A", "F1"] = 818
phonemes ["SL", "F", "A", "F2"] = 1197
phonemes ["SL", "F", "E", "F1"] = 668
phonemes ["SL", "F", "E", "F2"] = 1748
phonemes ["SL", "F", "I", "F1"] = 429
phonemes ["SL", "F", "I", "F2"] = 1937
phonemes ["SL", "F", "O", "F1"] = 571
phonemes ["SL", "F", "O", "F2"] = 882
phonemes ["SL", "F", "Y", "F1"] = 496
phonemes ["SL", "F", "Y", "F2"] = 1636
phonemes ["SL", "F", "Y:", "F1"] = 431
phonemes ["SL", "F", "Y:", "F2"] = 1695
phonemes ["SL", "F", "a", "F1"] = 854
phonemes ["SL", "F", "a", "F2"] = 1436
phonemes ["SL", "F", "au", "F1"] = 648
phonemes ["SL", "F", "au", "F2"] = 1057
phonemes ["SL", "F", "e", "F1"] = 430
phonemes ["SL", "F", "e", "F2"] = 1862
phonemes ["SL", "F", "ei", "F1"] = 620
phonemes ["SL", "F", "ei", "F2"] = 1718
phonemes ["SL", "F", "i", "F1"] = 294
phonemes ["SL", "F", "i", "F2"] = 1855
phonemes ["SL", "F", "o", "F1"] = 528
phonemes ["SL", "F", "o", "F2"] = 894
phonemes ["SL", "F", "u", "F1"] = 376
phonemes ["SL", "F", "u", "F2"] = 735
phonemes ["SL", "F", "ui", "F1"] = 613
phonemes ["SL", "F", "ui", "F2"] = 1559
phonemes ["SL", "F", "y", "F1"] = 321
phonemes ["SL", "F", "y", "F2"] = 1742
# Guessed
phonemes ["SL", "F", "@", "F1"] = 500.5
phonemes ["SL", "F", "@", "F2"] = 1706.6

# Triangle
# Male 
phonemes ["SL", "M", "i_corner", "F1"] = phonemes ["SL", "M", "i", "F1"]/(2^(1/12))
phonemes ["SL", "M", "i_corner", "F2"] = phonemes ["SL", "M", "i", "F2"]*(2^(1/12))
phonemes ["SL", "M", "a_corner", "F1"] = phonemes ["SL", "M", "a", "F1"]*(2^(1/12))
phonemes ["SL", "M", "a_corner", "F2"] = phonemes ["SL", "M", "a", "F2"]
phonemes ["SL", "M", "u_corner", "F1"] = phonemes ["SL", "M", "u", "F1"]/(2^(1/12))
phonemes ["SL", "M", "u_corner", "F2"] = phonemes ["SL", "M", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["SL", "M", "@_center", "F1"] =(phonemes ["SL", "M", "i_corner", "F1"]*phonemes ["SL", "M", "u_corner", "F1"]*phonemes ["SL", "M", "a_corner", "F1"])^(1/3)
phonemes ["SL", "M", "@_center", "F2"] = (phonemes ["SL", "M", "i_corner", "F2"]*phonemes ["SL", "M", "u_corner", "F2"]*phonemes ["SL", "M", "a_corner", "F2"])^(1/3)

# Female 
phonemes ["SL", "F", "i_corner", "F1"] = phonemes ["SL", "F", "i", "F1"]/(2^(1/12))
phonemes ["SL", "F", "i_corner", "F2"] = phonemes ["SL", "F", "i", "F2"]*(2^(1/12))
phonemes ["SL", "F", "a_corner", "F1"] = phonemes ["SL", "F", "a", "F1"]*(2^(1/12))
phonemes ["SL", "F", "a_corner", "F2"] = phonemes ["SL", "F", "a", "F2"]
phonemes ["SL", "F", "u_corner", "F1"] = phonemes ["SL", "F", "u", "F1"]/(2^(1/12))
phonemes ["SL", "F", "u_corner", "F2"] = phonemes ["SL", "F", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["SL", "F", "@_center", "F1"] =(phonemes ["SL", "F", "i_corner", "F1"]*phonemes ["SL", "F", "u_corner", "F1"]*phonemes ["SL", "F", "a_corner", "F1"])^(1/3)
phonemes ["SL", "F", "@_center", "F2"] = (phonemes ["SL", "F", "i_corner", "F2"]*phonemes ["SL", "F", "u_corner", "F2"]*phonemes ["SL", "F", "a_corner", "F2"])^(1/3)

# Vocal Tract Length
# Sex  VTL		Phi
# F    15.94	553.52
# M    17.11	516.05
averagePhi_VTL ["SL", "F"] = 553.52
averagePhi_VTL ["SL", "M"] = 516.05
# Classification boundary
averagePhi_VTL ["SL", "A"] = 529.80


###############################################
#
# Burg's method formant algorithm (Burg)
#
###############################################

# Male 
phonemes ["Burg", "M", "A", "F1"] = 743
phonemes ["Burg", "M", "A", "F2"] = 1075
phonemes ["Burg", "M", "E", "F1"] = 572
phonemes ["Burg", "M", "E", "F2"] = 1802
phonemes ["Burg", "M", "I", "F1"] = 383
phonemes ["Burg", "M", "I", "F2"] = 2037
phonemes ["Burg", "M", "O", "F1"] = 499
phonemes ["Burg", "M", "O", "F2"] = 712
phonemes ["Burg", "M", "Y", "F1"] = 425
phonemes ["Burg", "M", "Y", "F2"] = 1482
phonemes ["Burg", "M", "Y:", "F1"] = 388
phonemes ["Burg", "M", "Y:", "F2"] = 1514
phonemes ["Burg", "M", "a", "F1"] = 837
phonemes ["Burg", "M", "a", "F2"] = 1299
phonemes ["Burg", "M", "au", "F1"] = 606
phonemes ["Burg", "M", "au", "F2"] = 962
phonemes ["Burg", "M", "e", "F1"] = 376
phonemes ["Burg", "M", "e", "F2"] = 2117
phonemes ["Burg", "M", "ei", "F1"] = 513
phonemes ["Burg", "M", "ei", "F2"] = 1855
phonemes ["Burg", "M", "i", "F1"] = 261
phonemes ["Burg", "M", "i", "F2"] = 2183
phonemes ["Burg", "M", "o", "F1"] = 446
phonemes ["Burg", "M", "o", "F2"] = 721
phonemes ["Burg", "M", "u", "F1"] = 293
phonemes ["Burg", "M", "u", "F2"] = 654
phonemes ["Burg", "M", "ui", "F1"] = 501
phonemes ["Burg", "M", "ui", "F2"] = 1506
phonemes ["Burg", "M", "y", "F1"] = 268
phonemes ["Burg", "M", "y", "F2"] = 1608

# Guessed
phonemes ["Burg", "M", "@", "F1"] = 373
phonemes ["Burg", "M", "@", "F2"] = 1247

# Female
phonemes ["Burg", "F", "A", "F1"] = 878
phonemes ["Burg", "F", "A", "F2"] = 1236
phonemes ["Burg", "F", "E", "F1"] = 685
phonemes ["Burg", "F", "E", "F2"] = 1956
phonemes ["Burg", "F", "I", "F1"] = 435
phonemes ["Burg", "F", "I", "F2"] = 2260
phonemes ["Burg", "F", "O", "F1"] = 584
phonemes ["Burg", "F", "O", "F2"] = 885
phonemes ["Burg", "F", "Y", "F1"] = 504
phonemes ["Burg", "F", "Y", "F2"] = 1674
phonemes ["Burg", "F", "Y:", "F1"] = 437
phonemes ["Burg", "F", "Y:", "F2"] = 1745
phonemes ["Burg", "F", "a", "F1"] = 938
phonemes ["Burg", "F", "a", "F2"] = 1530
phonemes ["Burg", "F", "au", "F1"] = 677
phonemes ["Burg", "F", "au", "F2"] = 1074
phonemes ["Burg", "F", "e", "F1"] = 440
phonemes ["Burg", "F", "e", "F2"] = 2184
phonemes ["Burg", "F", "ei", "F1"] = 633
phonemes ["Burg", "F", "ei", "F2"] = 1951
phonemes ["Burg", "F", "i", "F1"] = 309
phonemes ["Burg", "F", "i", "F2"] = 2341
phonemes ["Burg", "F", "o", "F1"] = 540
phonemes ["Burg", "F", "o", "F2"] = 900
phonemes ["Burg", "F", "u", "F1"] = 391
phonemes ["Burg", "F", "u", "F2"] = 729
phonemes ["Burg", "F", "ui", "F1"] = 632
phonemes ["Burg", "F", "ui", "F2"] = 1655
phonemes ["Burg", "F", "y", "F1"] = 323
phonemes ["Burg", "F", "y", "F2"] = 1803

# Guessed
phonemes ["Burg", "F", "@", "F1"] = 440
phonemes ["Burg", "F", "@", "F2"] = 1415

# Triangle
# Male 
phonemes ["Burg", "M", "i_corner", "F1"] = phonemes ["Burg", "M", "i", "F1"]/(2^(1/12))
phonemes ["Burg", "M", "i_corner", "F2"] = phonemes ["Burg", "M", "i", "F2"]*(2^(1/12))
phonemes ["Burg", "M", "a_corner", "F1"] = phonemes ["Burg", "M", "a", "F1"]*(2^(1/12))
phonemes ["Burg", "M", "a_corner", "F2"] = phonemes ["Burg", "M", "a", "F2"]
phonemes ["Burg", "M", "u_corner", "F1"] = phonemes ["Burg", "M", "u", "F1"]/(2^(1/12))
phonemes ["Burg", "M", "u_corner", "F2"] = phonemes ["Burg", "M", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["Burg", "M", "@_center", "F1"] =(phonemes ["Burg", "M", "i_corner", "F1"]*phonemes ["Burg", "M", "u_corner", "F1"]*phonemes ["Burg", "M", "a_corner", "F1"])^(1/3)
phonemes ["Burg", "M", "@_center", "F2"] = (phonemes ["Burg", "M", "i_corner", "F2"]*phonemes ["Burg", "M", "u_corner", "F2"]*phonemes ["Burg", "M", "a_corner", "F2"])^(1/3)

# Female
phonemes ["Burg", "F", "i_corner", "F1"] = phonemes ["Burg", "F", "i", "F1"]/(2^(1/12))
phonemes ["Burg", "F", "i_corner", "F2"] = phonemes ["Burg", "F", "i", "F2"]*(2^(1/12))
phonemes ["Burg", "F", "a_corner", "F1"] = phonemes ["Burg", "F", "a", "F1"]*(2^(1/12))
phonemes ["Burg", "F", "a_corner", "F2"] = phonemes ["Burg", "F", "a", "F2"]
phonemes ["Burg", "F", "u_corner", "F1"] = phonemes ["Burg", "F", "u", "F1"]/(2^(1/12))
phonemes ["Burg", "F", "u_corner", "F2"] = phonemes ["Burg", "F", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["Burg", "F", "@_center", "F1"] =(phonemes ["Burg", "F", "i_corner", "F1"]*phonemes ["Burg", "F", "u_corner", "F1"]*phonemes ["Burg", "F", "a_corner", "F1"])^(1/3)
phonemes ["Burg", "F", "@_center", "F2"] = (phonemes ["Burg", "F", "i_corner", "F2"]*phonemes ["Burg", "F", "u_corner", "F2"]*phonemes ["Burg", "F", "a_corner", "F2"])^(1/3)

# Vocal Tract Length
# Sex  VTL   Phi
# F    15.39	573.59
# M    16.62	531.65
averagePhi_VTL ["Burg", "F"] = 573.59
averagePhi_VTL ["Burg", "M"] = 531.65
# Classification boundary
averagePhi_VTL ["Burg", "A"] = 529.48


###############################################
#
# Robust formant algorithm (Robust)
#
###############################################

# Male
phonemes ["Robust", "M", "A", "F1"] = 680
phonemes ["Robust", "M", "A", "F2"] = 1038
phonemes ["Robust", "M", "E", "F1"] = 510
phonemes ["Robust", "M", "E", "F2"] = 1900
phonemes ["Robust", "M", "I", "F1"] = 354
phonemes ["Robust", "M", "I", "F2"] = 2167
phonemes ["Robust", "M", "O", "F1"] = 446
phonemes ["Robust", "M", "O", "F2"] = 680
phonemes ["Robust", "M", "Y", "F1"] = 389
phonemes ["Robust", "M", "Y", "F2"] = 1483
phonemes ["Robust", "M", "Y:", "F1"] = 370
phonemes ["Robust", "M", "Y:", "F2"] = 1508
phonemes ["Robust", "M", "a", "F1"] = 797
phonemes ["Robust", "M", "a", "F2"] = 1328
phonemes ["Robust", "M", "au", "F1"] = 542
phonemes ["Robust", "M", "au", "F2"] = 945
phonemes ["Robust", "M", "e", "F1"] = 351
phonemes ["Robust", "M", "e", "F2"] = 2180
phonemes ["Robust", "M", "ei", "F1"] = 471
phonemes ["Robust", "M", "ei", "F2"] = 1994
phonemes ["Robust", "M", "i", "F1"] = 242
phonemes ["Robust", "M", "i", "F2"] = 2330
phonemes ["Robust", "M", "o", "F1"] = 393
phonemes ["Robust", "M", "o", "F2"] = 692
phonemes ["Robust", "M", "u", "F1"] = 269
phonemes ["Robust", "M", "u", "F2"] = 626
phonemes ["Robust", "M", "ui", "F1"] = 475
phonemes ["Robust", "M", "ui", "F2"] = 1523
phonemes ["Robust", "M", "y", "F1"] = 254
phonemes ["Robust", "M", "y", "F2"] = 1609

# Guessed
phonemes ["Robust", "M", "@", "F1"] = 373
phonemes ["Robust", "M", "@", "F2"] = 1247

# Female
phonemes ["Robust", "F", "A", "F1"] = 826
phonemes ["Robust", "F", "A", "F2"] = 1208
phonemes ["Robust", "F", "E", "F1"] = 648
phonemes ["Robust", "F", "E", "F2"] = 2136
phonemes ["Robust", "F", "I", "F1"] = 411
phonemes ["Robust", "F", "I", "F2"] = 2432
phonemes ["Robust", "F", "O", "F1"] = 527
phonemes ["Robust", "F", "O", "F2"] = 836
phonemes ["Robust", "F", "Y", "F1"] = 447
phonemes ["Robust", "F", "Y", "F2"] = 1698
phonemes ["Robust", "F", "Y:", "F1"] = 404
phonemes ["Robust", "F", "Y:", "F2"] = 1750
phonemes ["Robust", "F", "a", "F1"] = 942
phonemes ["Robust", "F", "a", "F2"] = 1550
phonemes ["Robust", "F", "au", "F1"] = 600
phonemes ["Robust", "F", "au", "F2"] = 1048
phonemes ["Robust", "F", "e", "F1"] = 409
phonemes ["Robust", "F", "e", "F2"] = 2444
phonemes ["Robust", "F", "ei", "F1"] = 618
phonemes ["Robust", "F", "ei", "F2"] = 2196
phonemes ["Robust", "F", "i", "F1"] = 271
phonemes ["Robust", "F", "i", "F2"] = 2667
phonemes ["Robust", "F", "o", "F1"] = 470
phonemes ["Robust", "F", "o", "F2"] = 879
phonemes ["Robust", "F", "u", "F1"] = 334
phonemes ["Robust", "F", "u", "F2"] = 686
phonemes ["Robust", "F", "ui", "F1"] = 594
phonemes ["Robust", "F", "ui", "F2"] = 1669
phonemes ["Robust", "F", "y", "F1"] = 285
phonemes ["Robust", "F", "y", "F2"] = 1765

# Guessed
phonemes ["Robust", "F", "@", "F1"] = 440
phonemes ["Robust", "F", "@", "F2"] = 1415

# Triangle
# Male
phonemes ["Robust", "M", "i_corner", "F1"] = phonemes ["Robust", "M", "i", "F1"]/(2^(1/12))
phonemes ["Robust", "M", "i_corner", "F2"] = phonemes ["Robust", "M", "i", "F2"]*(2^(1/12))
phonemes ["Robust", "M", "a_corner", "F1"] = phonemes ["Robust", "M", "a", "F1"]*(2^(1/12))
phonemes ["Robust", "M", "a_corner", "F2"] = phonemes ["Robust", "M", "a", "F2"]
phonemes ["Robust", "M", "u_corner", "F1"] = phonemes ["Robust", "M", "u", "F1"]/(2^(1/12))
phonemes ["Robust", "M", "u_corner", "F2"] = phonemes ["Robust", "M", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["Robust", "M", "@_center", "F1"] =(phonemes ["Robust", "M", "i_corner", "F1"]*phonemes ["Robust", "M", "u_corner", "F1"]*phonemes ["Robust", "M", "a_corner", "F1"])^(1/3)
phonemes ["Robust", "M", "@_center", "F2"] = (phonemes ["Robust", "M", "i_corner", "F2"]*phonemes ["Robust", "M", "u_corner", "F2"]*phonemes ["Robust", "M", "a_corner", "F2"])^(1/3)
                                              
# Female
phonemes ["Robust", "F", "i_corner", "F1"] = phonemes ["Robust", "F", "i", "F1"]/(2^(1/12))
phonemes ["Robust", "F", "i_corner", "F2"] = phonemes ["Robust", "F", "i", "F2"]*(2^(1/12))
phonemes ["Robust", "F", "a_corner", "F1"] = phonemes ["Robust", "F", "a", "F1"]*(2^(1/12))
phonemes ["Robust", "F", "a_corner", "F2"] = phonemes ["Robust", "F", "a", "F2"]
phonemes ["Robust", "F", "u_corner", "F1"] = phonemes ["Robust", "F", "u", "F1"]/(2^(1/12))
phonemes ["Robust", "F", "u_corner", "F2"] = phonemes ["Robust", "F", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["Robust", "F", "@_center", "F1"] =(phonemes ["Robust", "F", "i_corner", "F1"]*phonemes ["Robust", "F", "u_corner", "F1"]*phonemes ["Robust", "F", "a_corner", "F1"])^(1/3)
phonemes ["Robust", "F", "@_center", "F2"] = (phonemes ["Robust", "F", "i_corner", "F2"]*phonemes ["Robust", "F", "u_corner", "F2"]*phonemes ["Robust", "F", "a_corner", "F2"])^(1/3)

# Vocal Tract Length
# Sex  VTL   Phi
# F    15.24	579.27
# M    16.29	542.28
averagePhi_VTL ["Robust", "F"] = 579.27
averagePhi_VTL ["Robust", "M"] = 542.28
# Classification boundary
averagePhi_VTL ["Robust", "A"] = 546.36

###############################################
#
# KeepAll formant algorithm (KeepAll)
#
###############################################

# Male
phonemes ["KeepAll", "M", "A", "F1"] = 680
phonemes ["KeepAll", "M", "A", "F2"] = 1038
phonemes ["KeepAll", "M", "E", "F1"] = 510
phonemes ["KeepAll", "M", "E", "F2"] = 1900
phonemes ["KeepAll", "M", "I", "F1"] = 354
phonemes ["KeepAll", "M", "I", "F2"] = 2167
phonemes ["KeepAll", "M", "O", "F1"] = 446
phonemes ["KeepAll", "M", "O", "F2"] = 680
phonemes ["KeepAll", "M", "Y", "F1"] = 389
phonemes ["KeepAll", "M", "Y", "F2"] = 1483
phonemes ["KeepAll", "M", "Y:", "F1"] = 370
phonemes ["KeepAll", "M", "Y:", "F2"] = 1508
phonemes ["KeepAll", "M", "a", "F1"] = 797
phonemes ["KeepAll", "M", "a", "F2"] = 1328
phonemes ["KeepAll", "M", "au", "F1"] = 542
phonemes ["KeepAll", "M", "au", "F2"] = 945
phonemes ["KeepAll", "M", "e", "F1"] = 351
phonemes ["KeepAll", "M", "e", "F2"] = 2180
phonemes ["KeepAll", "M", "ei", "F1"] = 471
phonemes ["KeepAll", "M", "ei", "F2"] = 1994
phonemes ["KeepAll", "M", "i", "F1"] = 242
phonemes ["KeepAll", "M", "i", "F2"] = 2330
phonemes ["KeepAll", "M", "o", "F1"] = 393
phonemes ["KeepAll", "M", "o", "F2"] = 692
phonemes ["KeepAll", "M", "u", "F1"] = 269
phonemes ["KeepAll", "M", "u", "F2"] = 626
phonemes ["KeepAll", "M", "ui", "F1"] = 475
phonemes ["KeepAll", "M", "ui", "F2"] = 1523
phonemes ["KeepAll", "M", "y", "F1"] = 254
phonemes ["KeepAll", "M", "y", "F2"] = 1609

# Guessed
phonemes ["KeepAll", "M", "@", "F1"] = 373
phonemes ["KeepAll", "M", "@", "F2"] = 1247

# Female
phonemes ["KeepAll", "F", "A", "F1"] = 826
phonemes ["KeepAll", "F", "A", "F2"] = 1208
phonemes ["KeepAll", "F", "E", "F1"] = 648
phonemes ["KeepAll", "F", "E", "F2"] = 2136
phonemes ["KeepAll", "F", "I", "F1"] = 411
phonemes ["KeepAll", "F", "I", "F2"] = 2432
phonemes ["KeepAll", "F", "O", "F1"] = 527
phonemes ["KeepAll", "F", "O", "F2"] = 836
phonemes ["KeepAll", "F", "Y", "F1"] = 447
phonemes ["KeepAll", "F", "Y", "F2"] = 1698
phonemes ["KeepAll", "F", "Y:", "F1"] = 404
phonemes ["KeepAll", "F", "Y:", "F2"] = 1750
phonemes ["KeepAll", "F", "a", "F1"] = 942
phonemes ["KeepAll", "F", "a", "F2"] = 1550
phonemes ["KeepAll", "F", "au", "F1"] = 600
phonemes ["KeepAll", "F", "au", "F2"] = 1048
phonemes ["KeepAll", "F", "e", "F1"] = 409
phonemes ["KeepAll", "F", "e", "F2"] = 2444
phonemes ["KeepAll", "F", "ei", "F1"] = 618
phonemes ["KeepAll", "F", "ei", "F2"] = 2196
phonemes ["KeepAll", "F", "i", "F1"] = 271
phonemes ["KeepAll", "F", "i", "F2"] = 2667
phonemes ["KeepAll", "F", "o", "F1"] = 470
phonemes ["KeepAll", "F", "o", "F2"] = 879
phonemes ["KeepAll", "F", "u", "F1"] = 334
phonemes ["KeepAll", "F", "u", "F2"] = 686
phonemes ["KeepAll", "F", "ui", "F1"] = 594
phonemes ["KeepAll", "F", "ui", "F2"] = 1669
phonemes ["KeepAll", "F", "y", "F1"] = 285
phonemes ["KeepAll", "F", "y", "F2"] = 1765

# Guessed
phonemes ["KeepAll", "F", "@", "F1"] = 440
phonemes ["KeepAll", "F", "@", "F2"] = 1415

# Triangle
# Male
phonemes ["KeepAll", "M", "i_corner", "F1"] = phonemes ["KeepAll", "M", "i", "F1"]/(2^(1/12))
phonemes ["KeepAll", "M", "i_corner", "F2"] = phonemes ["KeepAll", "M", "i", "F2"]*(2^(1/12))
phonemes ["KeepAll", "M", "a_corner", "F1"] = phonemes ["KeepAll", "M", "a", "F1"]*(2^(1/12))
phonemes ["KeepAll", "M", "a_corner", "F2"] = phonemes ["KeepAll", "M", "a", "F2"]
phonemes ["KeepAll", "M", "u_corner", "F1"] = phonemes ["KeepAll", "M", "u", "F1"]/(2^(1/12))
phonemes ["KeepAll", "M", "u_corner", "F2"] = phonemes ["KeepAll", "M", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["KeepAll", "M", "@_center", "F1"] =(phonemes ["KeepAll", "M", "i_corner", "F1"]*phonemes ["KeepAll", "M", "u_corner", "F1"]*phonemes ["KeepAll", "M", "a_corner", "F1"])^(1/3)
phonemes ["KeepAll", "M", "@_center", "F2"] = (phonemes ["KeepAll", "M", "i_corner", "F2"]*phonemes ["KeepAll", "M", "u_corner", "F2"]*phonemes ["KeepAll", "M", "a_corner", "F2"])^(1/3)
                                              
# Female
phonemes ["KeepAll", "F", "i_corner", "F1"] = phonemes ["KeepAll", "F", "i", "F1"]/(2^(1/12))
phonemes ["KeepAll", "F", "i_corner", "F2"] = phonemes ["KeepAll", "F", "i", "F2"]*(2^(1/12))
phonemes ["KeepAll", "F", "a_corner", "F1"] = phonemes ["KeepAll", "F", "a", "F1"]*(2^(1/12))
phonemes ["KeepAll", "F", "a_corner", "F2"] = phonemes ["KeepAll", "F", "a", "F2"]
phonemes ["KeepAll", "F", "u_corner", "F1"] = phonemes ["KeepAll", "F", "u", "F1"]/(2^(1/12))
phonemes ["KeepAll", "F", "u_corner", "F2"] = phonemes ["KeepAll", "F", "u", "F2"]/(2^(1/12))
# @_center is not fixed but derived from current corners
phonemes ["KeepAll", "F", "@_center", "F1"] =(phonemes ["KeepAll", "F", "i_corner", "F1"]*phonemes ["KeepAll", "F", "u_corner", "F1"]*phonemes ["KeepAll", "F", "a_corner", "F1"])^(1/3)
phonemes ["KeepAll", "F", "@_center", "F2"] = (phonemes ["KeepAll", "F", "i_corner", "F2"]*phonemes ["KeepAll", "F", "u_corner", "F2"]*phonemes ["KeepAll", "F", "a_corner", "F2"])^(1/3)

# Vocal Tract Length
# Sex  VTL   Phi
# F    15.39	573.59
# M    16.62	531.65
averagePhi_VTL ["KeepAll", "F"] = 573.59
averagePhi_VTL ["KeepAll", "M"] = 531.65
# Classification boundary
averagePhi_VTL ["KeepAll", "A"] = 529.48


###############################################
#
# Start program: Non-Interactive
#
###############################################

# Run as a non interactive program
if input_table > 0
	selectObject: input_table
	.numInputRows = Get number of rows
	for .r to .numInputRows
		selectObject: input_table
		title$ = Get value: .r, "Title"
		# Skip rows that are commented out
		if startsWith(title$, "#")
			goto NEXTROW
		endif
		.sp$ = Get value: .r, "Speaker"
		if .sp$ = "A"
			.sp$ = "F"
			vtl_normalization = 1
		else
			vtl_normalization = 0
		endif
		file$ = Get value: .r, "File"
		tmp$ = Get value: .r, "Language"
		if index(tmp$, "[A-Z]{2}")
			uiLanguage$ = tmp$
		endif
		.log$ = Get value: .r, "Log"
		if index_regex(.log$, "\w")
			log = 1
			output_table$ = .log$
			if not fileReadable(output_table$)
				writeFileLine: output_table$, "Name", tab$, "Speaker", tab$, "N", tab$, "Area2", tab$, "Area1", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist", tab$, "VTL", tab$, "Duration", tab$, "Intensity", tab$, "Slope", tab$, "Formant"
			endif
		else
			log = 0
			output_table$ = "-"
		endif
		
		.plotFile$ = Get value: .r, "Plotfile"
		.plotVowels = 0
		if index_regex(.plotFile$, "\w") <= 0
			.plotFile$ = ""
		else
			.plotVowels = 1
		endif
		
		# Get the formant algorithm, if given
		.idx = Get column index: "Formant"
		if .idx > 0
			.formantAlgorithm$ = Get value: .r, "Formant"
			if index_regex(.formantAlgorithm$, "\w") > 0 and index(" SL Burg Robust KeepAll ", .formantAlgorithm$)
				targetFormantAlgorithm$ = .formantAlgorithm$
				plotFormantAlgorithm$ = targetFormantAlgorithm$
			endif
		endif

		# Handle cases where there is a wildcard
		if file$ <> "" and index_regex(file$, "[*]{1}") and index_regex(file$, "(?i\.(wav|mp3|aif[fc]))")
			.preFix$ = ""
			if index(file$, "/") > 0
				.preFix$ = replace_regex$(file$, "/[^/]+$", "/", 0)
			endif
			.fileList = Create Strings as file list: "FileList", file$
			.numFiles = Get number of strings
			.sound = -1
			for .f to .numFiles
				selectObject: .fileList
				.fileName$ = Get string: .f

				.tmp = Read from file: .preFix$ + .fileName$
				if .tmp <= 0 or numberOfSelected("Sound") <= 0
					exitScript: uiMessage$ [uiLanguage$, "ErrorSound"]
				endif
				name$ = selected$("Sound")
				.numChannels = Get number of channels
				if .numChannels > 1
					.maxInt = -10000
					.bestChannel = 1
					for .c to .numChannels
						selectObject: .tmp
						.tmpChannel = Extract one channel: .c
						.currentInt = Get intensity (dB)
						if .currentInt > .maxInt
							.maxInt = .currentInt
							.bestChannel = .c
						endif
						selectObject: .tmpChannel
						Remove
					endfor
					selectObject: .tmp
					.soundPart = Extract one channel: .bestChannel
				else
					selectObject: .tmp
					.soundPart = Copy: name$
				endif
				selectObject: .tmp
				Remove
				
				if .sound > 0
					selectObject: .sound, .soundPart
					.tmp = Concatenate
					.duration = Get total duration
					.intensity = Get intensity (dB)
					selectObject: .sound, .soundPart
					Remove
					.sound = .tmp
					.tmp = -1
				else
					.sound = .soundPart
				endif
			endfor
			selectObject: .fileList
			Remove
		elsif file$ <> "" and fileReadable(file$) and index_regex(file$, "(?i\.(wav|mp3|aif[fc]))")
			tmp = Read from file: file$
			if tmp <= 0 or numberOfSelected("Sound") <= 0
				exitScript: uiMessage$ [uiLanguage$, "ErrorSound"]
			endif
			name$ = selected$("Sound")
			.numChannels = Get number of channels
			if .numChannels > 1
				.maxInt = -10000
				.bestChannel = 1
				for .c to .numChannels
					selectObject: tmp
					.tmpChannel = Extract one channel: .c
					.currentInt = Get intensity (dB)
					if .currentInt > .maxInt
						.maxInt = .currentInt
						.bestChannel = .c
					endif
					selectObject: .tmpChannel
					Remove
				endfor
				selectObject: tmp
				.sound = Extract one channel: .bestChannel
			else
				selectObject: tmp
				.sound = Copy: name$
			endif
			selectObject: .sound
			.duration = Get total duration
			.intensity = Get intensity (dB)
			Rename: name$
			selectObject(tmp)
			Remove
		else
			exitScript: uiMessage$ [uiLanguage$, "ErrorSound"]
		endif
		
		if .plotVowels
			Erase all
			call set_up_Canvas
			#@plot_vowel_triangle: .sp$
			Text special... 0.5 Centre 1.05 bottom Helvetica 18 0 ##'title$'#
		endif
		@plot_vowels: .plotVowels, .sp$, .sound
		@print_output_line: title$, plot_vowels.sp$, plot_vowels.numVowelIntervals, plot_vowels.area2perc, plot_vowels.area1perc, plot_vowels.relDist_i, plot_vowels.relDist_u, plot_vowels.relDist_a, plot_vowels.vocalTractLength, .duration, .intensity, plot_vowels.slope

		if index_regex(.plotFile$, "\w")
			Select outer viewport: 0, 8, 0, 8
			Save as 300-dpi PNG file: .plotFile$
		endif
		
		selectObject: .sound
		Remove
		
		label NEXTROW
	endfor
	selectObject: input_table
	Remove
	
	exitScript: uiMessage$ [uiLanguage$, "Done"]
endif


###############################################
#
# Start program: Interactive
#
###############################################

# Run master loop
while .continue
	
	.titleVar$ = uiMessage$ [uiLanguage$, "Title"]
	.titleVar$ = replace_regex$(.titleVar$, "^([A-Z])", "\l\1", 0)
	.speakerIsA$ = uiMessage$ [uiLanguage$, "Speaker is a"]
	.speakerIsAVar$ = replace_regex$(.speakerIsA$, "^([A-Z])", "\l\1", 0)
	.speakerIsAVar$ = replace_regex$(.speakerIsAVar$, "\s*\(.*$", "", 0)
	.speakerIsAVar$ = replace_regex$(.speakerIsAVar$, "[\s.?!()/\\\\]", "_", 0)
	.languageInput$ = uiMessage$ [uiLanguage$, "Interface Language"]
	.languageInputVar$ = replace_regex$(.languageInput$, "^([A-Z])", "\l\1", 0)
	.languageInputVar$ = replace_regex$(.languageInputVar$, "\s*\(.*$", "", 0)
	.languageInputVar$ = replace_regex$(.languageInputVar$, "[\s.?!()/\\\\]", "_", 0)

	.recording = 0
	beginPause: "Select a recording"
		sentence: uiMessage$ [uiLanguage$, "Title"], uiMessage$ [uiLanguage$, "untitled"]
		comment: uiMessage$ [uiLanguage$, "CommentOpen"]
		comment: uiMessage$ [uiLanguage$, "CommentRecord"]
		choice: .speakerIsA$, .sp_default
			option: uiMessage$ [uiLanguage$, "Female"]
			option: uiMessage$ [uiLanguage$, "Male"]
			option: uiMessage$ [uiLanguage$, "Automatic"]
		optionMenu: .languageInput$, .defaultLanguage
			option: "English"
			option: "Nederlands"
			option: "Deutsch"
			option: "Français"
			option: "汉语"
			option: "Español"
			option: "Português"
			option: "Italiano"
		#   option: "MyLanguage"
		boolean: "Log", (output_table$ <> "")
		comment: uiMessage$ [uiLanguage$, "Experimental"]
		optionMenu: "Formant", .formant_default
			option: "SL"
			option: "Burg"
			option: "Robust"
			option: "Keep All"
	.clicked = endPause: (uiMessage$ [uiLanguage$, "Stop"]), (uiMessage$ [uiLanguage$, "Record"]), (uiMessage$ [uiLanguage$, "Open"]), 3, 1	
	if .clicked = 1
		.continue = 0
		.message$ = uiMessage$ [uiLanguage$, "Nothing to do"]
		@exitVowelTriangle: .message$
	elsif .clicked = 2
		.recording = 1
	endif

	title$ = '.titleVar$'$
	if title$ = uiMessage$ [uiLanguage$, "untitled"]
		title$ = "untitled"
	endif
	
	.sp$ = "M"
	vtl_normalization = 0
	.sp_default = 2
	.speakerIsAVar$ = replace_regex$(.speakerIsAVar$, " ", "_", 0)
	.speakerIsAVar$ = replace_regex$(.speakerIsAVar$, "^([A-Z])", "\l\1", 0)
	if uiMessage$ [uiLanguage$, "Female"] = '.speakerIsAVar$'$
		.sp$ = "F"
		.sp_default = 1
	elsif uiMessage$ [uiLanguage$, "Automatic"] = '.speakerIsAVar$'$
		.sp$ = "F"
		.sp_default = 3
		vtl_normalization = 1
	endif
	
	uiLanguage$ = "EN"
	.defaultLanguage = 1
	.display_language$ = '.languageInputVar$'$
	if .display_language$ = "Nederlands"
		uiLanguage$ = "NL"
		.defaultLanguage = 2
	elsif .display_language$ = "Deutsch"
		uiLanguage$ = "DE"
		.defaultLanguage = 3
	elsif .display_language$ = "Français"
		uiLanguage$ = "FR"
		.defaultLanguage = 4
	elsif .display_language$ = "汉语"
		uiLanguage$ = "ZH"
		.defaultLanguage = 5
	elsif .display_language$ = "Español"
		uiLanguage$ = "ES"
		.defaultLanguage = 6
	elsif .display_language$ = "Português"
		uiLanguage$ = "PT"
		.defaultLanguage = 7
	elsif .display_language$ = "Italiano"
		uiLanguage$ = "IT"
		.defaultLanguage = 8
	#
	# Add a new language
	# elsif .display_language$ = "MyLanguage"
	#	uiLanguage$ = "MyCode"
	#	.defaultLanguage = 9
	endif

	if formant$ = "Burg"
		plotFormantAlgorithm$ = "Burg"
		targetFormantAlgorithm$ = "Burg"
		.formant_default = 2
	elsif formant$ = "Robust"
		plotFormantAlgorithm$ = "Robust"
		targetFormantAlgorithm$ = "Robust"
		.formant_default = 3
	elsif formant$ = "Keep All"
		plotFormantAlgorithm$ = "KeepAll"
		targetFormantAlgorithm$ = "KeepAll"
		.formant_default = 4
	else
		plotFormantAlgorithm$ = "SL"
		targetFormantAlgorithm$ = "SL"
		.formant_default = 1
	endif
	
	# Store preferences
	writeFileLine: .preferencesLanguageFile$, "Language=",uiLanguage$
	appendFileLine: .preferencesLanguageFile$, "Formant=",targetFormantAlgorithm$
	
	# Start
	if log and output_table$ = ""
		Erase all
		Select outer viewport: 0, 8, 0, 8
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
			appendInfoLine: "Name", tab$, "Speaker", tab$, "N", tab$, "Area2", tab$, "Area1", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist", tab$, "VTL", tab$,"Duration", tab$, "Intensity", tab$, "Slope", tab$, "Formant"
		elsif index_regex(output_table$, "\w") and not fileReadable(output_table$)
			writeFileLine: output_table$, "Name", tab$, "Speaker", tab$, "N", tab$, "Area2", tab$, "Area1", tab$, "i.dist", tab$, "u.dist", tab$, "a.dist", tab$, "VTL", tab$, "Duration", tab$, "Intensity", tab$, "Slope", tab$, "Formant"
		endif
	endif
	
	# Write instruction
	Erase all
	Select outer viewport: 0, 8, 0, 8
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
	if read_and_select_audio.sound < 1
		goto NEXTROUND
	endif
	.sound = read_and_select_audio.sound
	if title$ = "untitled"
		title$ = replace_regex$(read_and_select_audio.filename$, "\.[^\.]+$", "", 0)
		title$ = replace_regex$(title$, "^.*/([^/]+)$", "\1", 0)
		title$ = replace_regex$(title$, "_", " ", 0)
	endif
		
	# Draw vowel triangle
	Erase all
	call set_up_Canvas
	#@plot_vowel_triangle: .sp$
	Text special... 0.5 Centre 1.05 bottom Helvetica 18 0 ##'title$'#
	
	selectObject: .sound
	.duration = Get total duration
	.intensity = Get intensity (dB)
	if .intensity > 50
		@plot_vowels: 1, .sp$, .sound, 
		@print_output_line: title$, plot_vowels.sp$, plot_vowels.numVowelIntervals, plot_vowels.area2perc, plot_vowels.area1perc, plot_vowels.relDist_i, plot_vowels.relDist_u, plot_vowels.relDist_a, plot_vowels.vocalTractLength, .duration, .intensity, plot_vowels.slope
	endif
	
	selectObject: .sound
	Remove
	
	
	# Save graphics
	.file$ = chooseWriteFile$: uiMessage$ [uiLanguage$, "SavePicture"], title$+"_VowelTriangle.png"
	if .file$ <> ""
		Select outer viewport: 0, 8, 0, 8
		Save as 300-dpi PNG file: .file$
	endif
	
	# Ready or not?
	beginPause: uiMessage$ [uiLanguage$, "DoContinue"]
		comment: uiMessage$ [uiLanguage$, "CommentContinue"]
	.clicked = endPause: (uiMessage$ [uiLanguage$, "Continue"]), (uiMessage$ [uiLanguage$, "Done"]), 2, 2
	.continue = (.clicked = 1)
	
	label NEXTROUND
endwhile

#####################################################################

procedure read_and_select_audio .type .message1$ .message2$
	.sound = -1
	if .type
		Record mono Sound...
		beginPause: (uiMessage$ [uiLanguage$, "PauseRecord"])
			comment: uiMessage$ [uiLanguage$, "CommentList"]
		.clicked = endPause: (uiMessage$ [uiLanguage$, "Stop"]), (uiMessage$ [uiLanguage$, "Continue"]), 2, 1
		if .clicked = 1
			pauseScript: (uiMessage$ [uiLanguage$, "Stopped"])
			goto RETURN
		endif
		if numberOfSelected("Sound") <= 0
			pauseScript: (uiMessage$ [uiLanguage$, "ErrorSound"])
			goto RETURN
		endif
		.source = selected ("Sound")
		.filename$ = "Recorded speech"
	else
		.filename$ = chooseReadFile$: .message1$
		if .filename$ = "" or not fileReadable(.filename$) or not index_regex(.filename$, "(?i\.(wav|mp3|aif[fc]))")
			pauseScript: (uiMessage$ [uiLanguage$, "No readable recording selected "])+.filename$
			goto RETURN
		endif
		
		.source = Open long sound file: .filename$
		.filename$ = selected$("LongSound")
		.fullName$ = selected$()
		.fileType$ = extractWord$ (.fullName$, "")
		if .fileType$ <> "Sound" and .fileType$ <> "LongSound"
			pauseScript:  (uiMessage$ [uiLanguage$, "ErrorSound"])+.filename$
			goto RETURN
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
		selectObject: .source
		Remove
		pauseScript: (uiMessage$ [uiLanguage$, "Stopped"])
		goto RETURN
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
	.numChannels = Get number of channels
	if .numChannels > 1
		.maxInt = -10000
		.bestChannel = 1
		for .c to .numChannels
			selectObject: .tmp
			.tmpChannel = Extract one channel: .c
			.currentInt = Get intensity (dB)
			if .currentInt > .maxInt
				.maxInt = .currentInt
				.bestChannel = .c
			endif
			selectObject: .tmpChannel
			Remove
		endfor
		selectObject: .tmp
		.sound = Extract one channel: .bestChannel
		Rename: .filename$
	else
		selectObject: .tmp
		.sound = Copy: .filename$
	endif

	selectObject: .tmp, .source
	Remove

	selectObject: .sound
	Rename: .filename$
	
	label RETURN
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
# .plot: Actually plot inside picture window or just calculate paramters
procedure plot_vowels .plot .sp$ .sound
	.startT = 0
	.dot_Radius = default_Dot_Radius
	#call syllable_nuclei -25 4 0.3 1 .sound
	#.syllableKernels = syllable_nuclei.textgridid
	call segment_syllables -25 4 0.3 1 .sound
	.syllableKernels = segment_syllables.textgridid
	
	# Calculate the formants
	selectObject: .sound
	.duration = Get total duration
	.soundname$ = selected$("Sound")
	if .sp$ = "M"
		.maxFormant = 5000
	else
		.maxFormant = 5500
	endif
	
	# Calculate Slope
	selectObject: .sound
	# Use only voiced intervals
	.pp = noprogress To PointProcess (periodic, cc): 50, 600
	.vuv = To TextGrid (vuv): 0.02, 0.01
	selectObject: .sound, .vuv
	Extract intervals where: 1, "no", "is equal to", "V"
	.numIntervals = numberOfSelected ()
	.sounds# = selected#("Sound")
	.voicedIntervals = Concatenate
	# Determine Ltas and slope
	.ltas = To Ltas: 100
	.slope = Get slope: 0, 1000, 1000, 10000, "dB"
	# Remove all intermediate objects
	selectObject: .ltas, .vuv
	for i to .numIntervals
		plusObject: .sounds#[i]
		Remove
	endfor
	plusObject: .voicedIntervals, .pp
	Remove

	# Targets
	# Calculate formants
	selectObject: .sound
	if targetFormantAlgorithm$ = "Burg"
		.formants = noprogress To Formant (burg): 0, 5, .maxFormant, 0.025, 50
		.formantsBandwidth = Copy: "Plot"
	elsif targetFormantAlgorithm$ = "Robust"
		.formants = noprogress To Formant (robust): 0.01, 5, .maxFormant, 0.025, 50, 1.5, 5, 1e-06
		.formantsBandwidth = Copy: "Bandwidth"
	elsif targetFormantAlgorithm$ = "KeepAll"
		.formants = noprogress To Formant (keep all): 0.01, 5, .maxFormant, 0.025, 50
		.formantsBandwidth = Copy: "Bandwidth"
	else
		selectObject: .sound
		.downSampled = Resample: 2*.maxFormant, 50
		.formants = noprogress To Formant (sl): 0, 5, .maxFormant, 0.025, 50
		selectObject: .downSampled
		Remove
		selectObject: .sound
		.formantsBandwidth = noprogress To Formant (burg): 0, 5, .maxFormant, 0.025, 50
	endif
	
	if targetFormantAlgorithm$ = plotFormantAlgorithm$
		.formantsPlot = .formants
	else
		selectObject: .sound
		if plotFormantAlgorithm$ = "Burg"
			.formantsPlot = noprogress To Formant (burg): 0, 5, .maxFormant, 0.025, 50
		elsif plotFormantAlgorithm$ = "Robust"
			.formantsPlot = noprogress To Formant (robust): 0.01, 5, .maxFormant, 0.025, 50, 1.5, 5, 1e-06
		elsif plotFormantAlgorithm$ = "KeepAll"
			formantsPlot = noprogress To Formant (keep all): 0, 5, .maxFormant, 0.025, 50
		else
			.downSampled = Resample: 2*.maxFormant, 50
			.formantsPlot = noprogress To Formant (sl): 0, 5, .maxFormant, 0.025, 50
			selectObject: .downSampled
			Remove
		endif
	endif
	
	# Plot
	@select_vowel_target: .sp$, .sound, .formants, .formantsBandwidth, .syllableKernels
	.vowelTier = select_vowel_target.vowelTier
	.targetTier = select_vowel_target.targetTier
	selectObject: .syllableKernels
	.numTargets = Get number of points: .targetTier
	if .numTargets > dot_Radius_Cutoff
		.dot_Radius = default_Dot_Radius / sqrt(.numTargets/dot_Radius_Cutoff)
	endif

	# Get Vocal Track Length
	.vtlScaling = 1
	.vocalTractLength = -1
	if vtl_normalization or not .plot
		@estimate_Vocal_Tract_Length: .formantsPlot, .syllableKernels, .targetTier
		.vocalTractLength = estimate_Vocal_Tract_Length.vtl
		if vtl_normalization
			.sp$ = "F"
			if estimate_Vocal_Tract_Length.phi < averagePhi_VTL [plotFormantAlgorithm$, "A"]
				.sp$ = "M"
			endif
			# Watch out .sp$ must be set BEFORE the scaling
			.vtlScaling = averagePhi_VTL [plotFormantAlgorithm$, .sp$] / estimate_Vocal_Tract_Length.phi
		endif
	endif
	
	# Draw new vowel triangle
	if .plot
		@plot_vowel_triangle: .sp$
	endif

	# Set new @_center
	phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F1"] = (phonemes [plotFormantAlgorithm$, .sp$, "a", "F1"] * phonemes [plotFormantAlgorithm$, .sp$, "i", "F1"] * phonemes [plotFormantAlgorithm$, .sp$, "u", "F1"]) ** (1/3) 
	phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F2"] = (phonemes [plotFormantAlgorithm$, .sp$, "a", "F2"] * phonemes [plotFormantAlgorithm$, .sp$, "i", "F2"] * phonemes [plotFormantAlgorithm$, .sp$, "u", "F2"]) ** (1/3) 
	
	.f1_c = phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F1"]
	.f2_c = phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F2"]
	
	# Plot center
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_c, .f2_c
	.st_c1 = vowel2point.x
	.st_c2 = vowel2point.y
	
	# Near /@/
	.f1_c = phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F1"]
	.f2_c = phonemes [plotFormantAlgorithm$, .sp$, "@_center", "F2"]
	@get_closest_vowels: 0, .sp$, .formants, .formantsPlot, .syllableKernels, .f1_c, .f2_c, .vtlScaling
	.numVowelIntervals = get_closest_vowels.vowelNum
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .vtlScaling, plotFormantAlgorithm$, .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["@"], .x, .y, .dot_Radius
		endfor
	endif
	
	# Near /i/
	.f1_i = phonemes [plotFormantAlgorithm$, .sp$, "i", "F1"]
	.f2_i = phonemes [plotFormantAlgorithm$, .sp$, "i", "F2"]
	@get_closest_vowels: 0, .sp$, .formants, .formantsPlot, .syllableKernels, .f1_i, .f2_i, .vtlScaling
	.meanDistToCenter ["i"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["i"] = get_closest_vowels.stdevDistance
	.num_i_Intervals = get_closest_vowels.vowelNum
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .vtlScaling, plotFormantAlgorithm$, .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["i"], .x, .y, .dot_Radius
		endfor
	endif
	
	# Near /u/
	.f1_u = phonemes [plotFormantAlgorithm$, .sp$, "u", "F1"]
	.f2_u = phonemes [plotFormantAlgorithm$, .sp$, "u", "F2"]
	@get_closest_vowels:  0, .sp$, .formants, .formantsPlot, .syllableKernels, .f1_u, .f2_u, .vtlScaling
	.meanDistToCenter ["u"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["u"] = get_closest_vowels.stdevDistance
	.num_u_Intervals = get_closest_vowels.vowelNum
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .vtlScaling, plotFormantAlgorithm$, .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["u"], .x, .y, .dot_Radius
		endfor
	endif
	
	# Near /a/
	.f1_a = phonemes [plotFormantAlgorithm$, .sp$, "a", "F1"]
	.f2_a = phonemes [plotFormantAlgorithm$, .sp$, "a", "F2"]
	@get_closest_vowels:  0, .sp$, .formants, .formantsPlot, .syllableKernels, .f1_a, .f2_a, .vtlScaling
	.meanDistToCenter ["a"] = get_closest_vowels.meanDistance
	.stdevDistToCenter ["a"] = get_closest_vowels.stdevDistance
	.num_a_Intervals = get_closest_vowels.vowelNum
	# Actually plot the vowels
	if .plot
		for .i to get_closest_vowels.vowelNum
			.f1 = get_closest_vowels.f1_list [.i]
			.f2 = get_closest_vowels.f2_list [.i]
			@vowel2point: .vtlScaling, plotFormantAlgorithm$, .sp$, .f1, .f2
			.x = vowel2point.x
			.y = vowel2point.y
			Paint circle: color$["a"], .x, .y, .dot_Radius
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
		@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_u, .f2_u	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
		# i
		@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_i, .f2_i	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
		# a
		@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_a, .f2_a	
		.x = vowel2point.x
		.y = vowel2point.y
		Black
		Solid line
		Draw line: .x-0.007, .y+0.007, .x+0.007, .y-0.007
		Draw line: .x-0.007, .y-0.007, .x+0.007, .y+0.007
	endif
	
	# Draw new triangle
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_i, .f2_i
	.st_i1 = vowel2point.x
	.st_i2 = vowel2point.y
	.ic_dist = sqrt((.st_c1 - .st_i1)^2 + (.st_c2 - .st_i2)^2)
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_u, .f2_u
	.st_u1 = vowel2point.x
	.st_u2 = vowel2point.y
	.uc_dist = sqrt((.st_c1 - .st_u1)^2 + (.st_c2 - .st_u2)^2)
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1_a, .f2_a
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
	.relDist = (.meanDistToCenter ["i"] + 1 * .stdevDistToCenter ["i"]) / .ic_dist
	.x ["i"] = .st_c1 + .relDist * (.st_i1 - .st_c1)
	.y ["i"] = .st_c2 + .relDist * (.st_i2 - .st_c2)
	# c - u
	.relDist = (.meanDistToCenter ["u"] + 1 * .stdevDistToCenter ["u"]) / .uc_dist
	.x ["u"] = .st_c1 + .relDist * (.st_u1 - .st_c1)
	.y ["u"] = .st_c2 + .relDist * (.st_u2 - .st_c2)
	# c - a
	.relDist = (.meanDistToCenter ["a"] + 1 * .stdevDistToCenter ["a"]) / .ac_dist
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
		.dY = 0
		if vtl_normalization
			.dY = 0.05
		endif
		.shift = Text width (world coordinates): " ('plotFormantAlgorithm$')"
		Text special: 1+.shift, "right", 0.07 + .dY, "bottom", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "AreaTitle"]+" ('plotFormantAlgorithm$')"
		Text special: 0.9, "right", 0.02 + .dY, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "Area1"]
		Text special: 0.9, "left", 0.02 + .dY, "bottom", "Helvetica", 14, "0", ": '.area1perc:0'\% "
		Text special: 0.9, "right", -0.03 + .dY, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "Area2"]
		Text special: 0.9, "left", -0.03 + .dY, "bottom", "Helvetica", 14, "0", ": '.area2perc:0'\% "
		Text special: 0.9, "right", -0.08 + .dY, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "AreaN"]
		Text special: 0.9, "left", -0.08 + .dY, "bottom", "Helvetica", 14, "0", ": '.numVowelIntervals' ('.duration:0' s, '.slope:1' dB)"
		if vtl_normalization
			Text special: 0.9, "right", -0.08, "bottom", "Helvetica", 14, "0", uiMessage$ [uiLanguage$, "VTL"]
			Text special: 0.9, "left", -0.08, "bottom", "Helvetica", 14, "0", ": '.vocalTractLength:1' cm"
		endif

		# Relative distance to corners
		Text special: -0.1, "left", 0.07 + .dY, "bottom", "Helvetica", 16, "0", uiMessage$ [uiLanguage$, "DistanceTitle"]
		Text special: 0.0, "right", 0.02 + .dY, "bottom", "Helvetica", 14, "0", "/i/:"
		Text special: 0.16, "right", 0.02 + .dY, "bottom", "Helvetica", 14, "0", " '.relDist_i:0'\%  ('.num_i_Intervals')"
		Text special: 0.0, "right", -0.03 + .dY, "bottom", "Helvetica", 14, "0", "/u/:"
		Text special: 0.16, "right", -0.03 + .dY, "bottom", "Helvetica", 14, "0", " '.relDist_u:0'\%  ('.num_u_Intervals')"
		Text special: 0.0, "right", -0.08 + .dY, "bottom", "Helvetica", 14, "0", "/a/:"
		Text special: 0.16, "right", -0.08 + .dY, "bottom", "Helvetica", 14, "0", " '.relDist_a:0'\%  ('.num_a_Intervals')"
	endif
	
	selectObject: .formants, .formantsBandwidth, .syllableKernels
	Remove
endproc

procedure print_output_line .title$, .sp$, .numVowelIntervals, .area2perc, .area1perc, .relDist_i, .relDist_u, .relDist_a, .vtl, .duration, .intensity, .slope
	# Uses global variable
	if output_table$ = "-"
		appendInfoLine: title$, tab$, .sp$, tab$, .numVowelIntervals, tab$, fixed$(.area2perc, 1), tab$, fixed$(.area1perc, 1), tab$, fixed$(.relDist_i, 1), tab$, fixed$(.relDist_u, 1), tab$, fixed$(.relDist_a, 1), tab$, fixed$(.vtl, 2), tab$, fixed$(.duration,0), tab$, fixed$(.intensity,1), tab$, fixed$(.slope,1), tab$, plotFormantAlgorithm$
	elsif index_regex(output_table$, "\w")
		appendFileLine: output_table$, title$, tab$, .sp$, tab$, .numVowelIntervals, tab$, fixed$(.area2perc, 1), tab$, fixed$(.area1perc, 1), tab$, fixed$(.relDist_i, 1), tab$, fixed$(.relDist_u, 1), tab$, fixed$(.relDist_a, 1), tab$, fixed$(.vtl, 2), tab$, fixed$(.duration,0), tab$, fixed$(.intensity,1), tab$, fixed$(.slope,1), tab$, plotFormantAlgorithm$
	endif	
endproc

# Plot the standard vowels
procedure plot_standard_vowel .color$ .sp$ .vowel$ .reduction
	.vowel$ = replace_regex$(.vowel$, "v", "y", 0)

	.i = 0
	while .vowel$ <> ""
		.i += 1
		.v$ = replace_regex$(.vowel$, "^\s*(\S[`]?).*$", "\1", 0)
		.f1 = phonemes [plotFormantAlgorithm$, .sp$, .v$, "F1"]
		.f2 = phonemes [plotFormantAlgorithm$, .sp$, .v$, "F2"]
		if .reduction
			.factor = 0.9^.reduction
			.f1 = .factor * (.f1 - phonemes [plotFormantAlgorithm$, .sp$, "@", "F1"]) + phonemes [plotFormantAlgorithm$, .sp$, "@", "F1"]
			.f2 = .factor * (.f2 - phonemes [plotFormantAlgorithm$, .sp$, "@", "F2"]) + phonemes [plotFormantAlgorithm$, .sp$, "@", "F2"]
		endif
		@vowel2point: 1, plotFormantAlgorithm$, .sp$, .f1, .f2
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
	.a_F1 = phonemes [plotFormantAlgorithm$, .sp$, "a_corner", "F1"]
	.a_F2 = phonemes [plotFormantAlgorithm$, .sp$, "a_corner", "F2"]

	.i_F1 = phonemes [plotFormantAlgorithm$, .sp$, "i_corner", "F1"]
	.i_F2 = phonemes [plotFormantAlgorithm$, .sp$, "i_corner", "F2"]

	.u_F1 = phonemes [plotFormantAlgorithm$, .sp$, "u_corner", "F1"]
	.u_F2 = phonemes [plotFormantAlgorithm$, .sp$, "u_corner", "F2"]
	
	Dashed line
	# u - i
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .u_F1, .u_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	Colour: color$ ["u"]
	Text special: .x1, "Centre", .y1, "Bottom", "Helvetica", 20, "0", "/u/ "+uiMessage$ [uiLanguage$, "Corneru"]
	Black
	
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .i_F1, .i_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Colour: color$ ["i"]
	Text special: .x2, "Centre", .y2, "Bottom", "Helvetica", 20, "0", uiMessage$ [uiLanguage$, "Corneri"]+" /i/"
	Black
	Draw line: .x1, .y1, .x2, .y2
	
	# u - a
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .u_F1, .u_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .a_F1, .a_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Colour: color$ ["a"]
	Text special: .x2, "Centre", .y2, "Top", "Helvetica", 20, "0", "/a/ "+uiMessage$ [uiLanguage$, "Cornera"]
	Black
	Draw line: .x1, .y1, .x2, .y2
	
	# i - a
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .i_F1, .i_F2
	.x1 = vowel2point.x
	.y1 = vowel2point.y
	@vowel2point: 1, plotFormantAlgorithm$, .sp$, .a_F1, .a_F2
	.x2 = vowel2point.x
	.y2 = vowel2point.y
	Draw line: .x1, .y1, .x2, .y2
endproc

# Convert the frequencies to coordinates
procedure vowel2point .scaling .targetFormantAlgorithm$ .sp$ .f1 .f2
	.scaleSt = 12*log2(.scaling)

	.spt1 = 12*log2(.f1)
	.spt2 = 12*log2(.f2)
	
	# Apply correction
	.spt1 += .scaleSt
	.spt2 += .scaleSt
	
	.a_St1 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "a_corner", "F1"])
	.a_St2 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "a_corner", "F2"])

	.i_St1 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "i_corner", "F1"])
	.i_St2 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "i_corner", "F2"])

	.u_St1 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "u_corner", "F1"])
	.u_St2 = 12*log2(phonemes [.targetFormantAlgorithm$, .sp$, "u_corner", "F2"])
	
	.dist_iu = sqrt((.i_St1 - .u_St1)^2 + (.i_St2 - .u_St2)^2)
	.theta = arcsin((.u_St1 - .i_St1)/.dist_iu)

	# First, with i_corner as (0, 0)
	.xp = ((.i_St2 - .spt2)/(.i_St2 - .u_St2))
	.yp = (.spt1 - min(.u_St1, .i_St1))/(.a_St1 - min(.u_St1, .i_St1))
	
	# Rotate around i_corner to make i-u axis horizontal
	.x = .xp * cos(.theta) + .yp * sin(.theta)
	.y = -1 * .xp * sin(.theta) + .yp * cos(.theta)
	
	# Reflect y-axis and make i_corner as (0, 1)
	.y = 1 - .y
	.yp = 1 - .yp
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
procedure get_closest_vowels .cutoff .sp$ .formants .formantsPlot .textgrid .f1_o .f2_o .scaling
	.f1 = 0
	.f2 = 0
	
	# Convert to coordinates
	@vowel2point: 1, targetFormantAlgorithm$, .sp$, .f1_o, .f2_o
	.st_o1 = vowel2point.x
	.st_o2 = vowel2point.y
	
	# Get center coordinates
	.fc1 = phonemes [targetFormantAlgorithm$, .sp$, "@_center", "F1"]
	.fc2 = phonemes [targetFormantAlgorithm$, .sp$, "@_center", "F2"]
	@vowel2point: 1, targetFormantAlgorithm$, .sp$, .fc1, .fc2
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
				@vowel2point: .scaling, targetFormantAlgorithm$, .sp$, .ftmp1, .ftmp2
				.stmp1 = vowel2point.x
				.stmp2 = vowel2point.y
				.tmpdistsqr = (.st_o1 - .stmp1)^2 + (.st_o2 - .stmp2)^2
				# Local
				if .tmpdistsqr < .numDistance
					.numDistance = .tmpdistsqr
					.numF1 = .ftmp1
					.numF2 = .ftmp2
					.num_t = .t
					.numF3 = Get value at time: 3, .num_t, "Hertz", "Linear"
					.numF4 = Get value at time: 4, .num_t, "Hertz", "Linear"
					.numF5 = Get value at time: 5, .num_t, "Hertz", "Linear"
				endif
				.t += 0.005
			endwhile
			
			# Convert to "real" (Burg) formant values
			if .formants != .formantsPlot
				selectObject: .formantsPlot
				.numF1 = Get value at time: 1, .num_t, "Hertz", "Linear"
				.numF2 = Get value at time: 2, .num_t, "Hertz", "Linear"
				.numF3 = Get value at time: 3, .num_t, "Hertz", "Linear"
				.numF4 = Get value at time: 4, .num_t, "Hertz", "Linear"
				.numF5 = Get value at time: 5, .num_t, "Hertz", "Linear"
			endif
			
			# Calculate the distance along the line between the 
			# center (c) and the target (t) from the best match 'v'
			# to the center.
			# 
			@vowel2point: .scaling, plotFormantAlgorithm$, .sp$, .numF1, .numF2
			.st1 = vowel2point.x
			.st2 = vowel2point.y
			
			.vcDist_sqr = (.st_c1 - .st1)^2 + (.st_c2 - .st2)^2
			.vtDist_sqr = (.st_o1 - .st1)^2 + (.st_o2 - .st2)^2
			.cvDist = (.tcDist_sqr + .vcDist_sqr - .vtDist_sqr)/(2*sqrt(.tcDist_sqr))
			
			# Only use positive distances for plotting
			if .cvDist = undefined or .cvDist >= .cutoff
				.vowelNum += 1
				.distance_list [.vowelNum] = sqrt(.numDistance)
				.f1_list [.vowelNum] = .numF1
				.f2_list [.vowelNum] = .numF2
				.f3_list [.vowelNum] = .numF3
				.f4_list [.vowelNum] = .numF4
				.f5_list [.vowelNum] = .numF5
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
		if .stdevDistance = undefined
			.stdevDistance = .meanDistance/2
		endif
		Remove
	endif
endproc

# Collect all the most distant vowels
procedure get_most_distant_vowels .sp$ .formants .textgrid .f1_o .f2_o .scaling
	.f1 = 0
	.f2 = 0
	
	# Convert to coordinates
	@vowel2point: 1, targetFormantAlgorithm$, .sp$, .f1_o, .f2_o
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
				@vowel2point: .scaling, targetFormantAlgorithm$, .sp$, .ftmp1, .ftmp2
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

procedure select_vowel_target .sp$ .sound .formants .formantsBandwidth .textgrid
	.f1_Lowest = phonemes [targetFormantAlgorithm$, .sp$, "i_corner", "F1"]
	.f1_Highest = (1050/900) * phonemes [targetFormantAlgorithm$, .sp$, "a_corner", "F1"]
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
	.samplingFrequency = Get sampling frequency
	.intensity = Get intensity (dB)
	selectObject: .formantsBandwidth
	.totalNumFrames = Get number of frames
		
	# Nothing found, but there is sound. Try to find at least 1 vowel
	
	selectObject: .textgrid
	.numPeaks = Get number of points: .peakTier	
	if .numPeaks <= 0 and .intensity >= 45
		selectObject: .sound
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
	
	selectObject: .sound
	.voicePP = noprogress To PointProcess (periodic, cc): 75, 600
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
		selectObject: .formantsBandwidth
		.b = Get bandwidth at time: 1, .tl, "Hertz", "Linear"
		.iframe = Get frame number from time: .tl
		.iframe = round(.iframe)
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
			selectObject: .formantsBandwidth
			.b = Get bandwidth at time: 1, .tl, "Hertz", "Linear"
			.iframe = Get frame number from time: .tl	
			.iframe = round(.iframe)
			if .iframe > .totalNumFrames
				.iframe = .totalNumFrames
			elsif .iframe < 1
				.iframe = 1
			endif
			.nf = Get number of formants: .iframe		
		endwhile

		selectObject: .formants
		.f = Get value at time: 1, .th, "Hertz", "Linear"
		selectObject: .formantsBandwidth
		.b = Get bandwidth at time: 1, .th, "Hertz", "Linear"
		.iframe = Get frame number from time: .th
		.iframe = round(.iframe)
		if .iframe > .totalNumFrames
			.iframe = .totalNumFrames
		elsif .iframe < 1
			.iframe = 1
		endif
		.nf = Get number of formants: .iframe
		while (.f < .f1_Lowest or .f > .f1_Highest or .b > 0.7 * .f or .nf < 4) and .th - .dt > .tl
			.th -= .dt
			selectObject: .formants
			.f = Get value at time: 1, .th, "Hertz", "Linear"
			selectObject: .formantsBandwidth
			.b = Get bandwidth at time: 1, .th, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			.iframe = round(.iframe)
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
			selectObject: .formantsBandwidth
			.b = Get bandwidth at time: 1, .ttl, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			.iframe = round(.iframe)
			if .iframe > .totalNumFrames
				.iframe = .totalNumFrames
			elsif .iframe < 1
				.iframe = 1
			endif
			.nf = Get number of formants: .iframe	
			
			# Voicing: Is there a voiced point below within 0.02 s?
			selectObject: .voicePP
			.i_near = Get nearest index: .ttl - .dt
			.pp_near = Get time from index: .i_near
			
			while (.f > .f1_Lowest and .f < .f1_Highest and .b < 0.9 * .f and .nf >= 4) and .ttl - .dt >= .tl and abs((.ttl - .dt) - .pp_near) <= 0.02
				.ttl -= .dt
				selectObject: .formants
				.f = Get value at time: 1, .ttl, "Hertz", "Linear"
				selectObject: .formantsBandwidth
				.b = Get bandwidth at time: 1, .ttl, "Hertz", "Linear"
				.iframe = Get frame number from time: .ttl
				.iframe = round(.iframe)
				if .iframe > .totalNumFrames
					.iframe = .totalNumFrames
				elsif .iframe < 1
					.iframe = 1
				endif
				.nf = Get number of formants: .iframe
				# Voicing: Is there a voiced point below within 0.02 s?
				selectObject: .voicePP
				.i_near = Get nearest index: .ttl - .dt
				.pp_near = Get time from index: .i_near
			endwhile
			# Make sure something has changed
			if .ttl > .tt - 0.01
				.ttl = .tl
			endif
			
			# Higher end
			.tth = .tp
			selectObject: .formants
			.f = Get value at time: 1, .tth, "Hertz", "Linear"
			selectObject: .formantsBandwidth
			.b = Get bandwidth at time: 1, .tth, "Hertz", "Linear"
			.iframe = Get frame number from time: .th
			.iframe = round(.iframe)
			if .iframe > .totalNumFrames
				.iframe = .totalNumFrames
			elsif .iframe < 1
				.iframe = 1
			endif
			.nf = Get number of formants: .iframe		
			
			# Voicing: Is there a voiced point above within 0.02 s?
			selectObject: .voicePP
			.i_near = Get nearest index: .ttl + .dt
			.pp_near = Get time from index: .i_near
			
			while (.f > .f1_Lowest and .f < .f1_Highest and .b < 0.9 * .f and .nf >= 4) and .tth + .dt <= .th and abs((.ttl + .dt) - .pp_near) <= 0.02
				.tth += .dt
				selectObject: .formants
				.f = Get value at time: 1, .tth, "Hertz", "Linear"
				selectObject: .formantsBandwidth
				.b = Get bandwidth at time: 1, .tth, "Hertz", "Linear"
				.iframe = Get frame number from time: .tth
				.iframe = round(.iframe)
				if .iframe > .totalNumFrames
					.iframe = .totalNumFrames
				elsif .iframe < 1
					.iframe = 1
				endif
				.nf = Get number of formants: .iframe		
				# Voicing: Is there a voiced point above within 0.02 s?
				selectObject: .voicePP
				.i_near = Get nearest index: .ttl + .dt
				.pp_near = Get time from index: .i_near
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
			.start = Get start time of interval: .vowelTier, .index
			.end = Get end time of interval: .vowelTier, .index
			# Last sanity checks on voicing and intensity
			# A vowel is voiced
			selectObject: .voicePP
			.meanPeriod = Get mean period: .start, .end, 0.0001, 0.02, 1.3
			if .meanPeriod <> undefined
				selectObject: .sound
				.sd = Get standard deviation: 1, .start, .end
				# Is there enough sound to warrant a vowel? > -15dB
				if 20*log10(.sd/(2*10^-5)) - .intensity > -15
					selectObject: .textgrid
					Set interval text: .vowelTier, .index, "Vowel"
				endif
			endif
		endif
	endfor
	
	selectObject: .voicePP
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
#                                                                         #
# Simplified summary of the script by Nivja de Jong and Ton Wempe         #
#                                                                         #
# Praat script to detect syllable nuclei and measure speech rate          # 
# automatically                                                           #
# de Jong, N.H. & Wempe, T. Behavior Research Methods (2009) 41: 385.     #
# https://doi.org/10.3758/BRM.41.2.385                                    #
# 
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
# Vocal Tract Length according to:
# Lammert, Adam C., and Shrikanth S. Narayanan. 
# “On Short-Time Estimation of Vocal Tract Length from Formant Frequencies.” 
# Edited by Charles R Larson. PLOS ONE 10, no. 7 (July 15, 2015): e0132193. 
# https://doi.org/10.1371/journal.pone.0132193.
#
# Iteratively, uses closest approach to (F1, F2) = (Phi, 3*Phi)
# 
procedure estimate_Vocal_Tract_Length .formants .syllableKernels .targetTier
	# Coefficients
	.beta[0] = 229
	.beta[1] = 0.030
	.beta[2] = 0.082
	.beta[3] = 0.124
	.beta[4] = 0.354
	
	.sp$ = "F"
	.phi = 500
	.vtl = -1
	
	.numTargets = -1
	for .iteration to 5
		@get_closest_vowels: -24, .sp$, .formants, .formants, .syllableKernels, .phi, 3*.phi, 1
		
		.numTargets = get_closest_vowels.vowelNum
		.n = 0
		.sumVTL = 0
		for .p to .numTargets
			.currentPhi = .beta[0]
			for .i to 4
				.f[.i] =  get_closest_vowels.f'.i'_list [.p]
				if .f[.i] <> undefined and .currentPhi <> undefined
					.currentPhi += .beta[.i] * .f[.i] / (2*.i - 1)
				else
					.currentPhi = undefined
				endif
			endfor
			if .currentPhi <> undefined
				.currentVTL = 100 * 352.95 / (4*.currentPhi)
				.sumVTL += .currentVTL
				.n += 1
			endif
		endfor
		
		if .n > 0
			.vtl = .sumVTL / .n
			# L = c / (4*Phi) (cm)
			.phi = 100 * 352.95 / (4*.vtl)
			
			.sp$ = "F"
			if .phi < averagePhi_VTL [plotFormantAlgorithm$, "A"]
				.sp$ = "M"
			endif
		endif
	endfor
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

# Initialize missing columns. Column names ending with a $ are text
procedure initialize_table_collumns .table, .columns$, .initial_value$
	.columns$ = replace_regex$(.columns$, "^\W+", "", 0)
	selectObject: .table
	.numRows = Get number of rows
	while .columns$ <> ""
		.label$ = replace_regex$(.columns$, "^\W*(\w+)\W.*$", "\1", 0)
		.columns$ = replace_regex$(.columns$, "^\W*(\w+)", "", 0)
		.textType = startsWith(.columns$, "$")
		if not .textType and index_regex(.initial_value$, "[0-9]") <= 0
			.textType = 1
		endif
		.columns$ = replace_regex$(.columns$, "^\W+", "", 0)
		.col = Get column index: .label$
		if .col <= 0
			Append column: .label$
			for .r to .numRows
				if .textType
					Set string value: .r, .label$, .initial_value$
				else
					Set value: .r, .label$, '.initial_value$'
				endif
			endfor
		endif
	endwhile
endproc
