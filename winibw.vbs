Sub AddSujetRAMEAU()
'Permet d'ajouter des 606
'Raccourci : Ctrl Shift (
'Requis : rien
	dim PPN, UB606, inds, Xvalue, PPNclean
	
	toEditMode false, false
	
With Application.activeWindow

	For i = 0 To 999
		inds = "##"
		PPN = Inputbox("Écrire le PPN à ajouter (en 606 (##) par défaut)"_
		& chr(10) & chr(10) & "-> $3{PPN} pour ajouter une subdivision au précédent"_
		& chr(10) & "-> Écrire '_{ind.1}{ind.2}' après le PPN SANS ESPACE pour changer les indicateurs par défaut"_
		& chr(10) & chr(10) & "NB : les indicateurs par défaut sont ceux entre parenthèses"_
		& chr(10) & chr(10) & "U0{PPN} pour ajouter 600 (#1)"_
		& chr(10) & "U1{PPN} pour ajouter 601 (02)"_
		& chr(10) & "U2{PPN} pour ajouter 602"_
		& chr(10) & "U4{PPN} pour ajouter 604"_
		& chr(10) & "U5{PPN} pour ajouter 605"_
		& chr(10) & "U7{PPN} pour ajouter 607"_
		& chr(10) & "U8{PPN} pour ajouter 608"_
		, "Ajouter une 60X:", "ok")
		PPN = Replace(PPN, "PPN ", "")
		PPN = Replace(PPN, "(PPN)", "")
		PPN = Replace(PPN, " ", "")
		PPN = Replace(PPN, chr(10), "")
		PPN = Replace(PPN, chr(13), "")
		
		.Title.EndOfbuffer
		If PPN = "ok" Then
			i = 1000
			.Title.InsertText UB606
		Else
			If Left(Right(PPN, 3), 1) = "_" Then
				inds = Right(PPN, 2)
			End If
			If Left(PPN, 2) = "$3" Then
				UB606 = Left(UB606, Len(UB606)-9) & PPN & right(UB606, 9)
			Else
				.Title.InsertText UB606
				PPNclean = Mid(PPN, 3, 9)
				Select Case UCase(Left(PPN, 2))
					Case "U0" Xvalue = "0"
						If inds = "##" Then
							inds = "#1"
						End If
					Case "U1" Xvalue = "1"
						If inds = "##" Then
							inds = "02"
						End If
					Case "U2" Xvalue = "2"
					Case "U4" Xvalue = "4"
					Case "U5" Xvalue = "5"
					Case "U7" Xvalue = "7"
					Case "U8" Xvalue = "8"
					Case Else Xvalue = "6"
						PPNclean = Left(PPN, 9)
				End Select
				UB606 = "60" & Xvalue & " " & inds & "$3" & PPNclean & "$2rameau" & chr(10)
			End If
		End If
	Next
	
End With

End Sub

Sub addUA400()
'Ajoute un/des champs 400 à une notice d'autorité auteur
'Basée sur la 200, elle décompose le  $a
'Raccourci : Ctrl Shift "
'Requis : decompUA200enUA400, toEditMode
'_A_MOD_

    dim z, sPos
    
    toEditMode false, false
    
With Application.activeWindow.Title
	
	z = .FindTag ("200")
	z = decompUA200enUA400(z)
	
	.endofbuffer
	.InsertText vblf & z
	
	'Ajoute une 400 à modifier si decompUA200enUA400 n'a pas renvoyer de 400
	If Len(z) < 5 Then
	    z = .FindTag ("200")
	    z = replace(z, "200", "400")
	    z = replace(z, "$90y", "")
	    sPos = inStr(z, "$f")
	    If sPos = 0 Then
	        sPos = inStr(z, "$c")
	    End If
	    z = Left(z, sPos-1)
	    
	    .endofbuffer
	    .InsertText vblf & z
	    .startoffield
	    .CharRight 8
	End If
    
End With

End Sub

Sub addUB700S3()
'Remplace la 700 actuelle de la notice bibliographique par une 700 contenant le PPN du presse-papier et le $4 de l'ancienne 700
'Raccourci : ctrl shift N
'Requis : countOccurrences, goToTag, toEditMode
	
	dim UB700, saveClipboard, notice
	dim nbOcc, exSB, nbOccRCR
	
	saveClipboard = Application.activeWindow.Clipboard
	toEditMode false, false

With Application.ActiveWindow.Title

	.SelectAll
	.copy
	notice = Application.activeWindow.Clipboard
	
	.Find(chr(10) & "700 ")
	.EndOfField
	.CharLeft 3, true
	.copy
	UB700 = "700 #1$3" & saveClipboard & "$4" & Application.activeWindow.Clipboard
	UB700 = replace(UB700, chr(10), "")
	.deleteLine
	
	.InsertText UB700 & vblf
	
	'Remplace le $btm des exemplaires du RCR ou signale la présence de plusieurs exemplaires dans l'ILN
	changeExAnom notice
	
	goToTag "101", "none", false, true, false
    
End With

    Application.activeWindow.Clipboard = saveClipboard
    
End Sub

Sub changeExAnom(notice)

With Application.activeWindow.Title
	nbOcc = countOccurrences(notice, chr(10) & "e", true)
	if nbOcc = 0 Then
	ElseIf nbOcc = 1 Then
		goToTag "930", "none", false, false, false
		.charLeft(1)
		.charLeft 2, true
		.copy
		If LCase(Application.activeWindow.clipboard) = "tm" Then
			.InsertText "x"
			exSB = .tag
			MsgBox exSB & " : tm remplacé par x"
		End If
	ElseIf nbOcc > 1 Then
		nbOccRCR = countOccurrences(notice, "$b330632101", true)
		If nbOccRCR > 1 Then
			.Find("$btm" & chr(10) & "930 ")
			exSB = .tag
			if Left(exSB, 1) = "e" Then
				MsgBox exSB & " à supprimer", , "Exemplaire fictif"
			Else
				MsgBox "Plusieurs exemplaires réels sur ce RCR." & chr(10) &"Fonds historique ?" & chr(10) &  chr(10) & "Vérification recommandée."
			End If
		Else
			MsgBox "Plusieurs exemplaires réels." & chr(10) & chr(10) & "Vérification recommandée."
		End If
	End If
End With
End Sub

Sub ChantierTheseAddUB183
'Ajoute une 183 en fonction de la 215 (notamment des chiffres détectés dans le $a) dans le cadre du chantier thèse
'Raccourci : Texte only
'Requis : goToTag, toEditMode
'_A_MOD_

	dim UB215, z, pages, numPages
	dim y(99)
	dim notice, nbSP, output, nbVblf, count
	
	notice = application.activeWindow.copyTitle
	toEditMode false, false

With Application.activeWindow.title
	
		'Détermine le $a à ecrire
		UB215 = .FindTag("215")
		z = split(UB215,"$")
		for each x in z
			if Left(x, 1) = "a" Then
				pages = x
			End If
		next
		If InStr(pages, "vol") <> 0 Then
			pages = Right(pages, Len(pages) - InStr(pages, "vol")-2)
		End If
		For i = 0 to Len(pages)
			y(i) = Mid(pages, i+1, 1)
			If isNumeric(y(i)) = true Then
				numPages = numPages & y(i)
			End If
		Next
		
	'determine le nb de $P
		'if countOccurrences(notice, "181 ##", true) >= countOccurrences(notice, "181 ##", true) Then
		'	nbSP = countOccurrences(notice, "181 ##", true)
		'Else
		'	nbSP = countOccurrences(notice, "182 ##", true)
		'End If
		'If nbSP = 1 Then
		'	output = "181 ##$P01"
		'Else 
	'Tant que je modifie pas
		output = "183 ##$P01"		



		if numPages < 49 Then
			output = output & "$angb"
		Else
			output = output & "$anga"
		End If
		
		goToTag "200", "none", false, true, false
		.InsertText output & vblf
		goToTag "215", "none", true, true, false
		
End With

End Sub

Sub ChantierTheseLoopAddUB183
'Exécute ChantierTheseAddUB183, sauf si l'utilisateur refuse l'ajout, sur la liste de PPN présente dans le presse-papier
'Raccourci : texte only
'Requis : ChantierTheseAddUB183, exportVar

	dim output, PPNList, statut, ListeStatuts, wrongPPN, count
	
	ListeStatuts = "ok" & chr(10) & "pb" & chr(10) & "no p" & chr(10) & "d f" & chr(10) & "$$stop"
	count = 0
	output = "$_#_$ Chantier thèse ajout UB183 : " & FormatDateTime(Now) & vblf & "PPN;Statut" & vblf
	
With Application.activeWindow

	PPNList = split(.clipboard, Chr(10))
	
	For each PPN in PPNList
		count = count +1
		wrongPPN = false
    		.command "che ppn " & PPN
    		If .Messages.Count > 0 Then
	    		If .messages.Item(0).Text = "PPN erroné" Then
	    			MsgBox "PPN erroné"
	    			wrongPPN = true
	    			statut = "PPN erroné"
	    		End If
	    	End if
	    	
	    	If wrongPPN = false Then
	    	
			chantierTheseAddUB183
			
	    		statut = Inputbox(.title.findtag("215") & chr(10) & ListeStatuts, "Définir le statut (PPN n°"&count&":", "ok")
	    		
	    		If statut = "ok" Then
				.SimulateIBWKey "FR"
			Else
				Select Case statut
					Case "pb" statut = "Problème"
					Case "no p" statut = "Pas de pagination"
					Case "d f" statut = "Déjà fait"
					Case "$$stop" statut = "Arrêt forcé"
					Case Else statut = "Statut invalide"
				End Select
				.SimulateIBWKey "FE"
				.SimulateIBWKey "FR"
	    		End If
	    	
	    	End If

    		output = output & PPN & ";" & statut & chr(10)
    		If Fix(count/10) = count/10 Then
    			output = Left(output, Len(output)-1)
    			exportVar output, true
    			output = ""
    		End If
    		If statut = "Arrêt forcé" Then
    			Exit For
    		End If
	Next
    
End With

	exportVar output, true

End Sub

Function CountOccurrences(p_strStringToCheck, p_strSubString, p_boolCaseSensitive)
'Renvoie le nombre d'occurrences
'Source : https://www.thoughtasylum.com/2009/07/30/VB-Script-Count-occurrences-in-a-text-string/ [cons. le 26/04/2021]
'Requis : RIEN

    Dim arrstrTemp
    Dim strBase, strToFind

    If p_boolCaseSensitive Then
        strBase = p_strStringToCheck
        strToFind = p_strSubString
    Else
        strBase = LCase(p_strStringToCheck)
        strToFind = LCase(p_strSubString)
    End If

    arrstrTemp = Split(strBase, strToFind)
    CountOccurrences = UBound(arrstrTemp)
End Function

Sub ctrlTraitementInterne
	
Dim PPNList, storedPPN, notice, Cote, count
Dim z, posRCR, posA98, posA, posJ

With Application.activeWindow

	PPNList = Split(.clipboard, chr(10))
	count = 0
	storedPPN = "X"
	output = "$_#_$ Contrôle traitement interne (getCote) : " & FormatDateTime(Now) & vblf & "PPN;Cote" & vblf
	
	For Each PPN in PPNList
		count = count+1
		.command "che ppn " & PPN
		If .variable("P3GPP") <> storedPPN Then
    z = .copyTitle
			If InStr(z, "930 ##$b330632101") <> 0 Then
    posRCR = InStr(z, "930 ##$b330632101")
    posA98 = InStrRev(z, "A98 330632101")
    z = Mid(z, posRCR, posA98-posRCR)
    posA = InStr(z,"$a")+2
    z = Mid(z, posA, Len(z)-posA)
'    posJ = InStr(z, chr(10))
'    z = Left(z, posJ) 
    output = output & PPN & z & vblf
    			Else
    				output = output & PPN & "Pas d'ex Sudoc" & vblf
			End If
			 
		Else
			output = output & PPN & ";ERROR;#n/a;Recherche non about." & vblf
		End If
	Next
	exportVar output, true

End With

End Sub

Sub ctrlUA103eqUA200f()
'Exporte et compare le $a de UA103 et le $f de UA200 pour chaque PPN de la liste présente dans le presse-papier.
'Requis : exportVar, getTag (quand implémenter obsvly)
'/!\ EVITER UTILISATION
'/!\ ATTENTION, WinIBW va sembler cesser de fonctionner, laissez-le faire

Dim PPNList, count, notice, UA103a, UA200f
Dim storedPPN, output

With Application.activeWindow

	count = 0
	storedPPN = "X"
	output = "$_#_$ Contrôle équivalence UA103 et UA200$f : " & FormatDateTime(Now) & vblf & "PPN;Result;UA103a;UA200f;Note" & vblf
	PPNList = split(.clipboard, Chr(10))
	
	For each PPN in PPNList
		count = count +1
		.command "che PPN " & PPN
		If .variable("P3GPP") <> storedPPN Then
			notice = .copyTitle
			UA103a = Mid(notice, InStr(notice, chr(13) & "103 ##")+9, 4)
			UA200f = Mid(notice, InStr(notice, chr(13) & "200 ")+6, Len(notice))
			UA200f = Mid(UA200f, InStr(UA200f, "$f") +2, 4)
			If UA103a = UA200f Then
				output = output & PPN & ";OK;" & UA103a & ";" & UA200f & ";#n/a" & vblf
			Else
				output = output & PPN & ";Diff;" & UA103a & ";" & UA200f & ";Pas corr. dates" & vblf
			End If
			storedPPN = Mid(notice, Instr(notice, chr(13) & "008 ")-9, 9)
			 
		Else
			output = output & PPN & ";ERROR;#n/a;#n/a;Recherche non about." & vblf
		End If

	Next
	exportVar output, true

End With

End Sub

Sub ctrlUB700S3()
'Exporte le premier $ de UB700 pour chaque PPN de la liste présente dans le presse-papie
'Requis : exportVar
'/!\ EVITER UTILISATION
'/!\ ATTENTION, WinIBW va sembler cesser de fonctionner, laissez-le faire

Dim PPNList, storedPPN, notice, UB700S_Occ1, count

With Application.activeWindow

	PPNList = Split(.clipboard, chr(10))
	count = 0
	storedPPN = "X"
	output = "$_#_$ Contrôle présence de lien UB700 : " & FormatDateTime(Now) & vblf & "PPN;Result;UB700S_Occ1" & vblf
	
	For Each PPN in PPNList
		count = count+1
		.command "che ppn " & PPN
		If .variable("P3GPP") <> storedPPN Then
			notice = .copyTitle
			UB700S_Occ1 = Mid(notice, InStr(notice, chr(13) & "700 ")+7, 2)
			If UB700S_Occ1 = "$3" Then
				output = output & PPN & ";OK;" & UB700S_Occ1 & vblf
			Else
				output = output & PPN & ";Diff;" & UB700S_Occ1 & vblf
			End If
			storedPPN = Mid(notice, Instr(notice, chr(13) & "008 ")-9, 9)
			 
		Else
			output = output & PPN & ";ERROR;#n/a;Recherche non about." & vblf
		End If
	Next
	exportVar output, true

End With

End Sub

Function decompUA200enUA400(impUA200)
'Renvoi les champs 400 créés à partir de la décomposition du nom composé du champ 200 importé
'Requis : RIEN
'_A_MOD_

    dim output, UA200aPos, UA200bPos, UA200b, UA200fPos, UA200cPos, UA400, UA400a, addUA400, dupName, IsDash
    
    decompUA200enUA400 = ""
    
    UA200aPos = InStr(impUA200, "$a")+2
    UA400 = Mid(impUA200, UA200aPos)
    UA200fPos = InStr(UA400, "$f")-1
    If UA200fPos > 0 Then
        UA400 = Left(UA400, UA200fPos)
    End If
    UA200cPos = InStr(UA400, "$c")-1
    If UA200cPos > 0 Then
        UA400 = Left(UA400, UA200cPos)
    End If
    UA200bPos = InStr(UA400, "$b")-1
    UA200b = Mid(UA400, UA200bPos+1)
    UA400a = Left(UA400, UA200bPos)
    
    While InStr(UA400a, " ") <> 0 OR InStr(UA400a, "-") <> 0
    
   	'Tiret ?
    	IsDash = FALSE
	If InStr(UA400a, "-") <> 0 Then
		IsDash = TRUE
		If InStr(UA400a, " ") <> 0 AND InStr(UA400a, "-") > InStr(UA400a, " ") Then
			IsDash = FALSE
		End If
	End If
	'msgBox isDash
	
	'Construction
	If isDash = TRUE Then
		dupName = Left(UA400a, InStr(UA400a, "-"))
		UA400a = Replace(UA400a, Left(UA400a, InStr(UA400a, "-")), "")
	Else
		dupName = Left(UA400a, InStr(UA400a, " ")-1)
		UA400a = Replace(UA400a, Left(UA400a, InStr(UA400a, " ")), "")
	End If
	'Modification du UA200b
	If Right(UA200b, 1) = "-" OR Right(UA200b, 1) = "'" Then
		UA200b = UA200b & dupName
	Else
		UA200b = UA200b & " " & dupName
	End If
	'Rejet du "de"
	If Left(UA400a, 3) = "de " Then
		UA400a = Mid(UA400a, 4, Len(UA400a))
		'UA200b = UA200b & " de"
		If Right(UA200b, 1) = "-" OR Right(UA200b, 1) = "'" Then
			UA200b = UA200b & "de"
		Else
			UA200b = UA200b & " de"
		End If
	End If
	'Rejet du "d'"
	If Left(UA400a, 2) = "d'" Then
		UA400a = Mid(UA400a, 3, Len(UA400a))
		'UA200b = UA200b & " d'"
		If Right(UA200b, 1) = "-" OR Right(UA200b, 1) = "'" Then
			UA200b = UA200b & "d'"
		Else
			UA200b = UA200b & " d'"
		End If
	End If

	addUA400 = "400 #1$a" & UA400a & UA200b
	
	'Ajout à la notice
	decompUA200enUA400 = decompUA200enUA400 & vblf & addUA400
    Wend

End Function

Sub exportVar(var, boolAppend)
'Exporte dans export.txt (même emplacement que winibw.vbs)
'Source : eddiejackson.net/wp/?p=8619
'Notes
'OpenTextFile parameters:
'IOMode
'1=Read
'2=write
'8=Append
'Create (true,false)
'Format (-2=System Default,-1=Unicode,0=ASCII)
'J'ai rajouté la var mode pour sélectionner entre append et write
'Requis : RIEN

	dim mode
	
	If boolAppend = true Then
		mode = 8
	Else
		mode = 2
	End If

	'À la BU
	Set objFileToWrite = CreateObject("Scripting.FileSystemObject").OpenTextFile("C:\/oclcpica/WinIBW30/Profiles/apeyrat001/export.txt",mode,true)
	'En TVW
	'Set objFileToWrite = CreateObject("Scripting.FileSystemObject").OpenTextFile("C:\/oclcpica/WinIBW30/Profiles/utilisateur/export.txt",mode,true)
	objFileToWrite.WriteLine(var)
	objFileToWrite.Close
	Set objFileToWrite = Nothing

End Sub

Sub getCoteEx()
'Renvoie dans le presse-papier la cote du document pour ce RCR (malfonctionne s'il y a plusieurs exemplaires de ce RCR)
'Raccourci : Ctrl+Shift+D
'Requis : RIEN

    dim z, posRCR, posA98, posA, posJ
    
With Application.activeWindow

    z = .copyTitle
    posRCR = InStr(z, "930 ##$b$_$#$_$RCR$_$#$_$")
    posA98 = InStrRev(z, "A98 $_$#$_$RCR$_$#$_$")
    z = Mid(z, posRCR, posA98-posRCR)
    posA = InStr(z,"$a")+2
    posJ = InStrRev(z, "$j")
    z = Mid(z, posA, posJ-posA)
    .Clipboard = z
    
End With

End Sub

Sub getTitle()
'Renvoie dans le presse papier le titre du document en remplaçant les @ et $e
'Raccourci : Ctrl Shift Q
'Requis : RIEN
'_A_MOD_

	dim z, y, x, i, posUB200, posUB2XX, posA, posF
    
With Application.activeWindow

	z = .copyTitle
	'Trouve le prochain champ pour délimiter la 200
	posUB200 = InStr(z, "200 ")
	i = 201
	posUB2xx = 0
	While posUB2XX = 0
	    x = i & " "
	    posUB2XX = InStr(z, x)
	    i = i + 1
	Wend
	
	z = Mid(z, posUB200, posUB2xx-posUB200)
	posA = InStr(z,"$a")+2
	posF = InStrRev(z, "$f")
	z = Mid(z, posA, posF-posA)
	z = replace(z, "@", "")
	z = replace(z, "$e", " : ")
	y = UCase(z)
	'Si le titre est uniquement en majuscule, le renovie en minuscule pour modifications
	if z = y Then
	     output = Left(z, 1) & Right(LCase(z), Len(z)-1)
	Else
	    output = z
	End If
	.Clipboard = output

End With

End Sub

Sub getUA810b()
'Si un seul UA810 est présent, écrit le $b "né le" à partir des informations de la 103de la notice
'Si plusieurs UA810 sont présents, renvoie le $b dans le presse-papier
'Raccourci : Ctrl+Shift+G
'Requis : countOccurrences, goToTag, toEditMode

	dim z, date, sexe, notice
	
	toEditMode false, false
	
With Application.activeWindow.title
	
	.selectAll
	.copy
	notice = Application.activeWindow.Clipboard
	
	'Construit le $b
	z = .FindTag ("103")
	z = Right(z, 8)
	sexe = .FindTag ("120")
	if Right(sexe, 1) = "a" Then
	sexe = "$bnée"
	Else
	sexe = "$bné"
	End If
	date = sexe & " le " & Right(z, 2) & "-" & Mid(z, 5,2) & "-" & Left(z, 4)
	
	'Compte le nombre de UA810 pour coller OU mettre dans presse papier
	If CountOccurrences(notice, "810 ##", false) = 1 Then
	 goToTag "810", "none", true, true, false
	 .insertText date
	Else
		  .selectNone
	    Application.ActiveWindow.Clipboard = date
	End If
    
End With

End Sub

Sub getUB310()
'Si une 310 est présente, récupère son information
'Raccourci : Ctrl+Shift++
'Requis : countOccurrences

	dim z, posUB310
	
	toEditMode true, false
	
With Application.activeWindow
	
	'Récupère la valeur du UB310
	z = .copyTitle
	z = Mid(z, InStr(z, "310 ##$a")+8)
	z = Left(z, InStr(z, chr(13))-1)
	.Clipboard = z
End With

End Sub

Sub goToTag(tag, subTag, toEndOfField, toFirst, toLast)
'Place le curseur à l'empalcement indiqué par les paramètres. Si plusieurs occurrences sont rencontrées sans que toFirst ou toLast soit true, une boîte de dialogue s'ouvre pour sélectionner l'occurrence souhaitée
'La fonction countOccurences est nécesssaire ( https://www.thoughtasylum.com/2009/07/30/VB-Script-Count-occurrences-in-a-text-string/ [cons. le 26/04/2021]
'Tag = [str] champ
'subtag = [str] [case sensitive] sous-champ. Ne pasz mettre le $. Si vide, mettre "none"
'toEndOfField = [bool] place le curseur à la fin du champ OU du sous-champ
'toFirst = [bool] si plusieurs occurences du CHAMP, sélectionne le premier prioritaire sur toLast
'toLast = [bool] si plusieurs occurences du CHAMP, sélectionne le dernier
'Requis : countOccurrences
'_A_MOD_

	Dim notice, nbVblf, nbOcc, occurrences, choseOcc, count
	Dim selectedTag, nbDollar, fromDollToEnd, nextDollar
	Dim clipboardSave    

With Application.activeWindow

	clipboardSave = .clipboard
	
	.title.selectAll
	.title.copy
	notice = .clipboard

End With

	choseOcc = false
	count = 1
	tag = CStr(tag)
	nbOcc = countOccurrences(notice, chr(10) & tag, false)
	If nbOcc > 1 Then
	  If toFirst = true Then
	  	count = 1
		ElseIf toLast = true Then
			count = nbOcc
		ElseIf toFirst = false AND toLast = false Then
			choseOcc = true
		End If
	ElseIf nbOcc = 0 Then
			MsgBox "Le champ " & tag & " n'a pas été trouvé dans la notice"
		Exit Sub
	End If
	
	'Old way
	nbVblf = split(notice, Chr(10))
	for each x in nbVblf
	    If Left(x, 3) = tag Then
	    	If choseOcc = false Then
	        	Exit For
	        Else
	        	occurrences = occurrences & vblf & count & " : " & x
	        	count = count + 1
	        End If
	    End If
	Next
	
	If choseOcc = true Then
		count = inputBox(occurrences, "Choisir le numéro de l'occurence")
		If isNumeric(count) = false Then
			MsgBox "Erreur. Choisir un NOMBRE. Relancer le script."
			Exit Sub
	  End If
	End If

With Application.activeWindow.Title

	    .find(chr(10) & tag)
	    If count > 1 Then
	    	for i = 2 to count
	    		.endOfField
	    		.LineDown(1)
	    	next
	    Else
	    	'.LineDown(1)
		.EndOfField
	    End If
	    
	    'Gestion du $
	    If subTag = "none" Then
		    If toEndOfField = true Then
		    	.EndOfField
		    Else
		    	.StartOfField
		    End If
	    Else
	      .StartOfField
	    	selectedTag = .currentField
	    	occurrences = ""
	      count = 0
	    	nbOcc = countOccurrences(selectedTag, "$" & subTag, true)
	    	If nbOcc = 0 Then
	    		MsgBox "Erreur. Pas de $" & subTag & " dans l'occurrence sélectionnée."
		      If toEndOfField = true Then
		      	.EndOfField
		      Else
		      	.StartOfField
		      End If
	    	ElseIf nbOcc = 1 Then
	      	.Find "$" & subTag, true, true
	      	.charRight(1)
	      	.charLeft(1)
		      If toEndOfField = true Then
		      	fromDollToEnd = Mid(selectedTag, InStr(selectedTag, "$" & subTag)+2, Len(selectedTag))
		      	nextDollar = InStr(fromDollToEnd, "$")
		      	If nextDollar = 0 Then
		      		.EndOfField
		      	Else
		      		.charRight(nextDollar-1)
		      	End If
		      End If
	      Else
		    'Si plusieurs occurrences du $   
		    nbDollar = split(selectedTag, "$")
		    for each x in nbDollar
		        If Left(x, 1) = subTag Then
		        	occurrences = occurrences & vblf & count & " : " & x
		        End If
		        count = count + 1
		    Next
		    count = inputBox(occurrences, "Choisir le numéro de l'occurence")
		    If isNumeric(count) = false Then
			MsgBox "Erreur. Choisir un NOMBRE. Première occurrence sélectionnée."
		  	.Find "$" & subTag, true, true
		  	.charRight(1)
		  	.charLeft(1)
		    End If
		  	.startOfField
			for i = 0 to count-1
				.charRight(Len(nbDollar(i))+1)
			next
			.charRight(1)
		      If toEndOfField = true Then
		      	.charRight(Len(nbDollar(count))-1)
		      End If
	    	End If
	    End If
End With
	    
    Application.activeWindow.clipboard = clipboardSave
    
	    End Sub

Sub goToTagInputBox()
'Permet d'essayer goToTag en indiquant les paramètres voulus.
'Requis : goToTag

	dim z, y, x, w, v
	z = inputbox("tag")
	v = inputbox("subTag", ,"none")
	y = inputbox("toEndOfField", , "false")
	x = inputbox("goFirst", , "false")
	w = inputbox("goLast", , "false")
	y = CBool(y)
	x = CBool(x)
	w = CBool(w)
	goToTag z, v, y, x, w
	'goToTag "606", "", true, "", ""
End Sub

Function PurifUB200a(UB200, isUB541)
'Requis : none
'_A_MOD_ -> mieux handle la provenance

	dim UB200a, UB200aPos, UB200fPos
	UB200aPos = InStr(UB200, "$a")+2
	If isUB541 = false Then
		UB200fPos = InStr(UB200, "$f")
	Else
		UB200fPos = InStr(UB200, "$z")
	End If
	UB200a = Mid(UB200, UB200aPos, UB200fPos - UB200aPos)
	UB200 = Replace(UB200, UB200a, "")
	UB200a = replace(UB200a, " : ", "$e")
	UB200a = replace(UB200a, ": ", "$e")
	'Ajoute le @
	If Left(UB200a, 6)="De la " Then
		UB200a = Left(UB200a, 6) & "@" & Mid(UB200a, 7, Len(UB200a))
	ElseIf Left(UB200a, 5)="De l'" Then
		UB200a = Left(UB200a, 5) & "@" & Mid(UB200a, 6, Len(UB200a))
	ElseIf Left(UB200a, 4)="Les "_
	OR Left(UB200a, 4)="Des "_
	OR Left(UB200a, 4)="Une "_
	OR Left(UB200a, 4)="The " Then
		UB200a = Left(UB200a, 4) & "@" & Mid(UB200a, 5, Len(UB200a))
	ElseIf Left(UB200a, 3)="Le "_
	OR Left(UB200a, 3)="La "_
	OR Left(UB200a, 3)="Un "_
	OR Left(UB200a, 3)="An "_
	OR Left(UB200a, 3)="De "_
	OR Left(UB200a, 3)="Du " Then
		UB200a = Left(UB200a, 3) & "@" & Mid(UB200a, 4, Len(UB200a))
	ElseIf Left(UB200a, 2)="A "_
	OR Left(UB200a, 2)="L'"_
	OR Left(UB200a, 2)="D'"  Then
		UB200a = Left(UB200a, 2) & "@" & Mid(UB200a, 3, Len(UB200a))
	Else
		UB200a = "@" & UB200a
	End If
	PurifUB200a = Left(UB200, UB200aPos-1) & UB200a & Mid(UB200, UB200aPos, Len(UB200))
	
End Function

Sub searchExcelPPNList()
'Recherche la liste de PPN contenu dans le presse-papier
'Raccourci : texte only
'Requis : RIEN

    Dim query
    
With Application.activeWindow
    
    query = "che ppn " & replace(.Clipboard, Chr(10), " OR ")
    query = Left(query, Len(query)-4)
    .Clipboard = query
    .Command query
    
End With

End Sub

Sub Sleep(time)
'Source : Original Paulie D comment : https://stackoverflow.com/questions/1729075/how-to-set-delay-in-vbscript
'EVITER L'UTILISATION
	Dim dteWait
	time = CInt(time)
	dteWait = DateAdd("s", time, Now())
	Do Until (Now() > dteWait)
	Loop
End Sub

Sub toEditMode(lgPMode, save)
'Passe en mode édition (ou présentation)
'lgPMode [bool] : true = passer en mode présentation
'save [bool] : si lgPMode =true, alors sauvegarder les changements ou non
'Requis : RIEN

dim z, editMode

With Application.activeWindow

	On Error Resume Next
	z = .title.canPaste

	if Err then
		editMode = false
	Else
		editMode = true
	End If

	If lgPMode = false Then
		If editMode = false Then
			.command "mod"
		End If
	Else
		If editMode = false Then
			If save = true Then
				.SimulateIBWKey "FR"
			Else
				.SimulateIBWKey "FE"
				.SimulateIBWKey "FR"
			End If
		End If
	End If
End With
End Sub
