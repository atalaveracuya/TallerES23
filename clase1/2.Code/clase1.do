


clear all 
set more off 
global ruta "E:\ANDRES\Documents\GitHub\TallerES23\" // Ubicación del proyecto. Rutear


* ---------------------------------------------------------				
* Paso 0. Generar carpeta del proyecto 
* --------------------------------------------------------

 mkdir "$ruta\clase1"           
 mkdir "$ruta\clase1\1.Data"
 mkdir "$ruta\clase1\1.Data/1.raw"
 mkdir "$ruta\clase1\1.Data/2.intermedio"
 mkdir "$ruta\clase1\1.Data/3.final"
 mkdir "$ruta\clase1\2.Code" 
 mkdir "$ruta\clase1\3.Resultados"
 mkdir "$ruta\clase1\3.Resultados\figuras"
 mkdir "$ruta\clase1\3.Resultados\mapas"
 mkdir "$ruta\clase1\3.Resultados\tablas"
 mkdir "$ruta\clase1\4.Doc"

*---------------------------------------------------------				
* Paso 1. Rutear Direccion de carpeta
* --------------------------------------------------------
cls 
clear 

global clases 	"$ruta\clase1" 
global main 	"${clases}\1.Data"			          // Data
global raw  	"${clases}\1.Data\1.raw"
global interm  	"${clases}\1.Data\2.intermedio" 
global out  	"${clases}\1.Data\3.final" 
global code 	"${clases}\2.Code" 
global figura	"${clases}\3.Resultados\figuras"	 // Figuras 
global mapa		"${clases}\3.Resultados\mapas"	    // Mapas  
global tablas	"${clases}\3.Resultados\tablas"	   // Tablas

*--------------------------------------------------
* Paso 2: Carga de data
*--------------------------------------------------

cd $raw    

use sumaria-2022.dta,clear 
br 
br ig0* ing* 
recode ig0*  ing* (.=0) 

* Dpto sin Callao para merge con deflactores:

br ubigeo

gen dpto= real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)


label define Andres 1 "Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
label list Andres

label value dpto Andres  
codebook dpto 

ssc install fre, replace  // instalo el comando fre  

fre dpto 


* ---------------------------------

* Dpto con Callao 
gen dpto2= real(substr(ubigeo,1,2))
gen prov= (substr(ubigeo,1,4))
label define dpto2 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto2 dpto2 

gen LimMetro=.
replace LimMetro=1 if dpto2==7
replace LimMetro=1 if prov=="1501"

* Dpto, Provincia de Lima y Region Lima 

gen dpto3=.
replace dpto3=dpto2 if dpto2<15
replace dpto3=129 if prov=="1501" // Provincia de Lima 
replace dpto3=130 if dpto2==15 & LimMetro!=1 // Region Lima 
replace dpto3=dpto2 if (dpto2>15 & dpto3==.)

label define dpto3 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Prov Const del Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" /*
*/ 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 129 "Provincia de Lima" 130 "Lima Provincias" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" /* 
*/ 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"

label values dpto3 dpto3
gen _ID=dpto3

*Ambito urbano/rural 

replace estrato = 1 if dominio ==8 
gen area = estrato <6
replace area=2 if area==0
label define area 2 rural 1 urbana
label val area area

*Dominios geográficos
gen domin02=1 if dominio>=1 & dominio<=3 & area==1
replace domin02=2 if dominio>=1 & dominio<=3 & area==2
replace domin02=3 if dominio>=4 & dominio<=6 & area==1
replace domin02=4 if dominio>=4 & dominio<=6 & area==2
replace domin02=5 if dominio==7 & area==1
replace domin02=6 if dominio==7 & area==2
replace domin02=7 if dominio==8

label define domin02 1 "Costa_urbana" 2 "Costa_rural" 3 "Sierra_urbana" 4 "Sierra_rural" 5 "Selva_urbana" 6 "Selva_rural" 7 "Lima_Metropolitana"
label value domin02 domin02
recode domin02 (1 3 5 = 1 "Resto urbano") (2 4 6 = 2 "Rural") (7 = 3 "Lima Metropolitana") , gen(Areas)

rename a*o aniorec
destring aniorec,replace  
merge m:1 aniorec dpto using deflactores_base2022_new.dta
*keep if _merge==3
*Ingreso real por habitante mensual, 2022 
*describe g*
*describe i* 
g irpcm=inghog1d/(12*mieperho*i00*ld)  //Ingreso real por habitante 
g grpcm=gashog2d/(12*mieperho*i00*ld)  //Gasto real por habitante 
gen facpob=factor07*mieperho

* Gasto monetario per cápita promedio mensual
* -----------------------------------------------

gen gpcm = gashog2d/(12*mieperho)
lab var gpcm "Gasto percápita mensual"


* Indicadores de Pobreza monetaria y vulnerabilidad 
* ------------
rename pobrezav vuln 
la var vuln  "pobreza y vulnerabilidad"

recode pobreza (1/2=1 "Pobre") (3=0 "No pobre"), gen(pobre)
lab var pobre "Pobreza monetaria"	
	

gen pobrvul=. 
replace pobrvul=0 if linea<gpcm & lineav<gpcm // no pobre no vulnerable 
replace pobrvul=1 if linea<gpcm & lineav>gpcm // no pobre vulnerable 
replace pobrvul=2 if linea>gpcm & linpe<gpcm // pobre no extremo 
replace pobrvul=3 if linpe>gpcm  // pobre extremo 


la def pobrvul 0 "no pobre no vulnerable" 1 "no pobre vulnerable" 2 "pobre no extremo" 3 "pobre extremo"
la val pobrvul pobrvul
la var pobrvul "Pobreza y Vulnerabilidad"

recode pobrvul (0=0 "no pobre no vulnerable") (1=1 "no pobre vulnerable") (2/3=2 "pobre") , gen(pvul)
keep conglome vivienda hogar year 

save "$out/sum2022.dta",replace   
 
svyset [iweight = facpob], psu(conglome) strata(estrato) singleunit(centered) 
svy: tab pvul //pobreza y vulnerabilidad 
svy: mean linea //linea de pobreza (Costo de canasta básica de consumo)
svy: mean linpe // linea de pobreza extrema (Costo de canasta básica de consumo de alimentos)

*Número estimado de pobres  
 tabout pvul [iw=facpob]  using  "$Tablas\pvul_gen.xls", replace c(freq) f(1)
 svy: tabulate pvul, count format(%14.3gc)
 svy: tabulate pvul, percent format(%14.3gc)
 tabstat pobre [aw=facpob] if pobre!=. , stats(mean sum) format(%11.6gc) by(dpto3)

