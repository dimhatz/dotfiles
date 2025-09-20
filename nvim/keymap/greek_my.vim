" Vim Keymap file for greek
" Maintainer: Grigorios Magklis <maglis@cs.rochester.edu>
" Last Updated: Tue 10 Jul 2001 16:50:50
" Modified by dimhatz for utf8
"
" This keyboard layout allows all Greek symbols to be typed,
" including accented capitals, diaeresis & accent on the same
" vowel, and the Greek semicolon sign.
"
" accent			";" + letter
" diaeresis			":" + letter
" diaeresis + accent		";" + ":" (or ":" + ";") + letter
" semicolon			"q"
" colon				"Q"
" greek semicolon		"W"
" sigma at end of word		"w"
" greek left double-quote	"<" twice
" greek right double-quote	">" twice

" Use this short name in the status line.
let b:keymap_name = "gr"

loadkeymap
" capital
A	Α
B	Β
G	Γ
D	Δ
E	Ε
Z	Ζ
H	Η
U	Θ
I	Ι
K	Κ
L	Λ
M	Μ
N	Ν
J	Ξ
O	Ο
P	Π
R	Ρ
S	Σ
T	Τ
Y	Υ
F	Φ
X	Χ
C	Ψ
V	Ω

" small
a	α
b	β
g	γ
d	δ
e	ε
z	ζ
h	η
u	θ
i	ι
k	κ
l	λ
m	μ
n	ν
j	ξ
o	ο
p	π
r	ρ
w	ς
s	σ
t	τ
y	υ
f	φ
x	χ
c	ψ
v	ω

" accented capital
;A	Ά
;E	Έ
;H	Ή
;I	Ί
;Y	Ύ
;O	Ό
;V	Ώ
"
:I	Ϊ
:Y	Ϋ

" accented small
;a	ά
;e	έ
;h	ή
;i	ί
;y	ύ
;o	ό
;v	ώ
"
:i	ϊ
:y	ϋ
"
;:i	ΐ
:;i	ΐ
;:y	ΰ
:;y	ΰ

" symbols
q	;		" ;
Q	:		" :
W	·
;	΄
:	¨
;:	΅
:;	΅

" quotes
<<	«
>>	»
