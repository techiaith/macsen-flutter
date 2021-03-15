# Macsen - Ap cynorthwyydd llais Cymraeg / Welsh language voice assistant app.

[click here to read this page in English](README_en.md)

Mae Macsen yn ap cynorthwyydd llais Cymraeg cod agored ar gyfer ffonau symudol a
thabledi Android ac iOS. Mae’n bosib siarad ar lafar gyda ap Macsen mewn Cymraeg 
naturiol er mwyn ofyn iddo gwblhau tasgau neu ofyn am wybodaeth.

Rydyn ni’n defnyddio’r project hwn i ddangos beth allwn ni greu wrth ddatblygu 
technoleg lleferydd a deallusrwydd artiffisial Cymraeg. Rydym yn cyhoeddi’r cydrannau 
a’r adnoddau perthnasol yma yn agored yma ar GitHub, er mwyn i ddatblygwyr 
eraill hefyd fedru’u defnyddio. Rydyn ni wrthi yn gwneud ymchwil pellach i’w wella, 
a’i alluogi mewn sefyllfaoedd eraill.

<a href="https://apps.apple.com/gb/app/macsen/id1489915663?mt=8">
    <img style="width: 135px; height: auto; margin-top: 7px;" src="https://linkmaker.itunes.apple.com/en-us/badge-lrg.svg?releaseDate=2020-03-18&amp;kind=iossoftware&amp;bubble=ios_apps"> 
</a>
<a href="https://play.google.com/store/apps/details?id=cymru.techiaith.flutter.macsen">
    <img width="145px" height="auto" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play">
</a>


## Sgiliau

Hyd yn hyn, mae gan ap Macsen 8 sgìl:

– Darllen y **newyddion**

– Adrodd am y **tywydd**

– Chwarae **cerddoriaeth Cymraeg** ar Spotify

– Gosod **larwm**

– Dweud yr **amser**

– Rhoi’r **dyddiad**

– Darllen brawddegau cyntaf erthyglau o **Wicipedia Cymraeg**

– Dangos rhaglenni teledu drwy gwefan **Clic S4C**

## Pensaernïaeth Macsen yn syml

Mae ap Macsen yn defnyddio nifer o gydrannau gwahanol sy'n gweithredu ar y ddyfais 
a dros y we. 

Wedi i chi ofyn ar lafar i Macsen am gymorth, defnyddir yn gyntaf adnabod lleferydd 
Mozilla DeepSpeech i drosi’r hyn yr ydych yn ei ddweud i destun.  

Yn dilyn hynny, mae technoleg adnabod bwriad, fel y gwelir mewn sgwrsfotiaid, yn 
ceisio deall o'r testun os yw'r cais am newyddion, y tywydd, cerddoriaeth neu un 
o’r sgiliau eraill. 

Wedi iddo ddeall y bwriad, mae'r meddalwedd yn ceisio ffurfio ymateb drwy estyn data
o API drydydd parti (e.e. tywydd heddiw o ddarpariaeth API OpenWeatherMap) ac/neu
cynhyrchu brawddegau iaith naturiol sy'n cynnwys y wybodaeth a ofynnwyd am. 

Yna er mwyn ateb ar lafar, mae’n gwneud hynny drwy ddefnyddio technoleg 
testun-i-leferydd Cymraeg a ddwyieithog i lefaru’r ymateb priodol.

Mae rhagor o wybodaeth am y technolegau hyn a’r Gymraeg ar gael yn y [Llawlyfr 
Technolegau Iaith](https://www.porth.ac.uk/cy/collection/llawlyfr-technolegau-iaith) 
a gyhoeddwyd gan y Coleg Cymraeg Cenedlaethol.


## Defnyddio cod Macsen

Mae holl adnoddau Macsen, o'r cod Flutter yn y repo hwn, i'r sgriptiau hyfforddi
modelau adnabod lleferydd a bwriad, i'r lleisiau testun-i-leferydd yn god agored
ac ar gael i ddatblygwyr a sefydliadau i addasu ac ehangu Macsen eu 
hunain, defnyddio o fewn sgwrfotiaid a cynorthwyon eraill neu unrhyw fath
o broject trawsnewid digidol.

Ewch i'r ddogfennaeth ar gyfer datblygwyr os hoffech chi ddysgu rhagor.


## Cyfrannu lleisiau

Rydym yn dal wrthi yn gwella’r nodweddion lleferydd, ac os hoffech chi, gallwch 
ein helpu i’w wella yn y dyfodol drwy gyfrannu recordiadau o’ch llais. 

Gallwch wneud hyn o fewn yr ap drwy glicio ar Hyfforddi yno. Bydd hyn yn eich 
arwain i ddarllen yn uchel y brawddegau sy’n cael eu hadnabod ar gyfer pob sgìl 
yn yr ap. 

Byddwn yn defnyddio’r recordiadau hyn i greu setiau datblygu a setiau profi ar 
gyfer hyfforddi’r adnabod lleferydd. 

Os ydych am gyfrannu mwy na hyn, ewch i wefan CommonVoice Mozilla i recordio 
brawddegau ar gyfer y casgliad mawr o recordiadau.


## Diolchiadau

Ariannwyd yr ap a’r gwaith adnabod lleferydd gan Lywodraeth Cymru, ac rydym yn 
diolch iddyn nhw ac i’r gwirfoddolwyr sydd wedi bod yn cyfrannu eu lleisiau i 
wella technoleg lleferydd. 

Diolch hefyd i Golwg360, Wicipedia ac i S4C am eu cymorth a chydweithrediad.

## Cydnabyddiaeth a Chyfeirio

Os defnyddiwch chi'r adnodd hwn, gofynnwn yn garedig i chi gydnabod a chyfeirio at 
ein gwaith. Mae cydnabyddiaeth o'r fath yn gymorth i ni sicrhau cyllid yn y dyfodol 
i greu rhagor o adnoddau defnyddiol i'w rhannu.

Gwelir rhagor o wybodaeth ar http://techiaith.cymru/macsen
