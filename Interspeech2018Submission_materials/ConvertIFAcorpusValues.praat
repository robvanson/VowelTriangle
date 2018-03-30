#! Praat
#
# Convert VowelTriangle variable.tsv to R format
#
# Copyright: 2017-2018, R.J.J.H. van Son and the Netherlands Cancer Institute
# License: GNU GPL v2 or later
# email: r.j.j.h.vanson@gmail.com, r.v.son@nki.nl
# 
#     ConvertIFAcorpusValues.praat: Praat script to practice vowel pronunciation 
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

form Variable.tsv table
	sentence Table variable.tsv
	sentence Target IFA_corpus_data.tsv
endform

.table = Read from file: table$
.fullName$ = selected$()
.type$ = extractWord$(.fullName$, "")
if .type$ <> "Table"
	exitScript: .fullName$, " is not a valid Table"
endif

Set column label (label): "Speaker", "Sex"
Insert column: 2, "Num"
Insert column: 2, "Style"
Insert column: 2, "Session"
Insert column: 2, "SessionNum"
Insert column: 2, "Age"
Insert column: 2, "Speaker"

selectObject: .table
.numRows = Get number of rows
.numCols = Get number of columns
for .r to .numRows
	selectObject: .table
	# Check values for undefined
	for .c to .numCols
		.label$ = Get column label: .c
		.value$ = Get value: .r, .label$
		if .value$ = "?" or .value$ = "" or .value$ = "--undefined--"
			Set string value: .r, .label$, "-"
		endif
	endfor
	
	# Determine values
	.name$ = Get value: .r, "Name"
	.i = 2
	.age$ = mid$(.name$, .i, 2)
	.i += 2
	.speaker$ = mid$(.name$, .i, 1)
	.i += 1
	.sessionNum$ = mid$(.name$, .i, 1)
	.i += 1
	.session$ = mid$(.name$, .i, 1)
	.i += 1
	.style$ = mid$(.name$, .i, 1)
	.i += 1
	.num$ = right$(.name$, length(.name$) + 1 - .i)

	Set string value: .r, "Age", .age$
	Set string value: .r, "Speaker", .speaker$
	Set string value: .r, "SessionNum", .sessionNum$
	Set string value: .r, "Session", .session$
	Set string value: .r, "Style", .style$
	Set string value: .r, "Num", .num$

endfor

selectObject: .table
Save as tab-separated file: target$

selectObject: .table
Remove
