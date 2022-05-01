breed [personas persona]
breed [virus viru]
globals [aforoActual tickPorDia Dia es porcentajesNiños porcentajesAdultos porcentajesMayores Choy Uhoy Mhoy Curahoy tickdia cerrado]

virus-own
[
  velocity-x             ; particle velocity in the x axis
  velocity-y             ; particle velocity in the y axis
  force-accumulator-x    ; force exerted in the x axis
  force-accumulator-y    ; force exerted in the y axis
  vida
]

patches-own[
  cargaEstantes;
]

personas-own
[Edad
  lista
  posLista
  carga
  contagiado
  mascarilla
  guantesPuestos
  subiendo
  salir
  Pasillo
  DiaEstado; es el dia que cambian de estado
  UCI
  muerto
  curado
  comprando
  Edad
  Curarse;Esto sera true para aquellas personas que lleven la enfermedad bien y se curaran en unos 20 dias despues de los sintomas

]

to setup
  clear-all
  reset-ticks
  ask patches ;ponemos el mapa en blanco
   [
  set pcolor white
]
  set Choy 0
  set Mhoy 0
  set Uhoy 0
  set Curahoy 0
  ;Vamos a definir donde van las estanterias segun el tamaño de los pasillos
  if AnchuraPasillos = 2 [
  set es [3 6 9 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57]
  ]
  if AnchuraPasillos = 3 [
  set es [4 8 12 16 20 24 28 32 36 40 44 48 52 56]
  ]
  if AnchuraPasillos = 4 [
  set es [5 10 15 20 25 30 35 40 45 50 55]
  ]
  if AnchuraPasillos = 5 [
  set es [6 12 18 24 30 36 42 48 54 ]
  ]
  if AnchuraPasillos = 6 [
  set es [7 14 21 28 35 42 49 56 ]
  ]

  ;voy a añadir los porcentajes de ir a la uci o de morir. Los porcentajes de la uci los voy a calcular directamente en la tabla con los datos de UCI y los contagiados de cada Rango de edad

  set porcentajesNiños [2.6 0.35 ] ; %uci %RIP
  set  porcentajesAdultos [3.0 0.65]; %uci %RIP
  set  porcentajesMayores[4.5 15.4]; %uci %RIP
  ;(55 * 100 / 2069) %uci NIÑO
  ;(2554 * 100 / 82807) %uci ADULTO
  ;(4951 * 100 / 111000) % UCI MAYORES

  foreach es  ;creamos las estanterias
  [x ->
    ask patches with [pxcor >= x and pxcor <( x + 1 ) and pycor > 5 and pycor < 55][
      set pcolor brown
      set CargaEstantes 0
      ]
    ]


    ask patches with [pxcor < 1 or pxcor > 59 ][ ;creamos las paredes izquierda y derecha
      set pcolor black
      ]

  ask patches with [(pycor < 1 and (pxcor < 30 or pxcor > 30)) or pycor > 59  ][; creamos las paredes arriba y abajo
      set pcolor black
      ]

  ask patches with [ (pxcor = 30 and pycor = 0) ][ ;creamos la entrada
   set pcolor blue
  ]

  ask patches with [ (pxcor > 60 and pycor <= 25) ][ ;creamos la calle
   set pcolor gray
  ]
  ask patches with [ (pxcor > 60 and pycor <= 45 and pycor > 25 ) ][ ;creamos UCI
   set pcolor blue
  ]
  ask patches with [ (pxcor > 60 and pycor >= 46) ][ ;creamos el cementerio
   set pcolor green
  ]

  set aforoActual 0
  set tickPordia 1200
  set dia 1
  create-personas Poblacion ;Creamos la problacion con sus atributos
  [
    ;Buscamos 4 num aleatorios y si coincide con un pasillo vamos al siguiente parche
    ;Esto lo utilizamos para hacer la lista de pasillos que vamos a visitar

    let a (random 59) + 1
    let pas position a es
    if pas != false [set a a + 1]

    let b (random 59) + 1
    set pas position b es
    if pas != false [set b b + 1]

    let c (random 59) + 1
    set pas position c es
    if pas != false [set c c + 1]

    let d (random 59) + 1
    set pas position d es
    if pas != false [set d d + 1]

    let g (random 59) + 1
    set pas position g es
    if pas != false [set g g + 1]

    let f (random 59) + 1
    set pas position f es
    if pas != false [set f f + 1]

    set lista (list a b c d f g)

    set Pasillo item posLista lista; marcamos el pasillo al que vamos primero
    ; Inicializamos los demas atributos
    set subiendo true
    setxy ((random 8) + 62) random 25
    facexy 0 ycor
    set size 3
    set salir false
    set comprando false
    set label-color black
    ;Añadimos los guantes y las mascarillas y metemos la label para que se vea en plena ejecucion
    ifelse random 100 < Mascarillas [set mascarilla true ] [set mascarilla false]
    ifelse random 100 < Guantes [set guantesPuestos true] [set guantesPuestos false]
    ifelse guantesPuestos = true and mascarilla = true [set label "MG"]
    [
     if guantesPuestos = true  [set label "G"]
     if  mascarilla = true [set label "M"]
    ]
    ;añadimos los contagiados iniciales
     ifelse random 100 <= Contagiados_Iniciales [set contagiado true set diaEstado 2 + 5 + random 12 set color red set carga 40 ] [set contagiado false set color blue set carga 0]
    set UCI false
    set muerto false
    set curado false
    set curarse false

    ; Para edar una poblacion similar a la de españa vamos a utilizar lo siguiente
    ifelse random 100 < 19 ; 19% de personas mayores
    [set Edad 60 + random 45]

    [ifelse random 100 < 15 ; 15% de porcentaje de niños
      [set Edad random 18 ]

      [set Edad random 18 + random 42 ]; da la edad desde los 18 hasta los 60
    ]
  ]



end


to go
  if tickdia = tickpordia [;vemos cuando cambiamos de dia
  set dia dia + 1
  let diaAux dia / 7
  set cerrado false
    if diaAux = round diaAux [ set cerrado true];controlaEstados show dia  set dia dia + 1];si divido el dia entre 7 y sale un numero entero es que es un domingo y controlo los que pasan de estado esos dias y paso de dia

    ;reseteamos la cuenta de cada dia
  set Choy 0
  set Mhoy 0
  set Uhoy 0
  set Curahoy 0
  set tickdia 0;lo utilizo para controlar el aforo

    if dia = 61 [stop]

   controlaEstados



  foreach es  ;limpiamos las estanterias
  [x ->
    ask patches with [pxcor >= x and pxcor <( x + 1 ) and pycor > 5 and pycor < 55][
      set pcolor brown
      set CargaEstantes 0
      ]
    ]

  ]



  ask patches with[cargaEstantes > 10][set pcolor red]; coloreamos los estantes con mucha carga virica

  ;Vamos a implementar el aforo por vayes
  let aforoVariable aforoMax * 0.8; control afluencia normal

  if tickdia < 200 or (tickdia >  600 and tickdia <  800) [if AforoMax > 6 [set aforoVariable aforoMax * 0.6] ];control afluencia minima
  if (tickdia > 300 and tickdia <  500) or (tickdia >  1000 and ticks <  1100) [if AforoMax > 6 [set aforoVariable aforoMax] ];control afluencia maxima
  if cerrado = true [ set aforoVariable  0]

  ;Vamos metiendo gente segun el aforo
  ask personas with [comprando = false and UCI = false and muerto = false and aforoVariable > aforoActual and random 100 < 1]
  [
    set aforoActual aforoActual + 1
    ifelse AforoMax + 1 > aforoActual[ ;este if es necesario porque si no hay un problema de exclusion mutua y se saltan el aforo
    setxy 30 2
    set comprando true;
     set posLista  6 - TiempoCompra ; al tamaño de la lista le quito el timpo de la compra para saber por donde empiezo la lista ( 6 - 6 = 0, empiezo de la pos 0 de la lista)
     if Contagiado = false [set carga 0] ;Una dosis de carga virica muy pequeña es eleminada rapidademnte por el cuerpo
    ]
    [set aforoActual aforoActual - 1]; si no cumple el aforo, me salgo

  ]



  ;Esta es la ejecucion de los que estan comprando
  ask personas with [comprando = true]; vemos si nos llega carga virica por el aire
  [
    if contagiado = false[; no hemos encontrado referencia que con mascarillas haya menos probabilidad de coger el virus
     set carga carga + count virus in-cone 3 180
      ask virus in-cone 3 180 [die]
    ]


    if carga > 40 and contagiado = false and curado = false[ ;segun os estudios vistos los cotagiados tienen 5.2 log10 ARN/ml del por lo que vamos a tomar como 40 particulas como la carga necesaria para ser contagiado
       set color red
       set contagiado true
      set Choy Choy + 1
      set DiaEstado dia + 2 + 5 + random 12
    ]
     ;nos movemos por los pasillos
    if (xcor > Pasillo)[moverIzquierda]
    if(xcor < Pasillo) [moverDerecha]
    ifelse(xcor = Pasillo and subiendo = true and salir = false) [subirPasillo]
    [if(xcor = Pasillo and subiendo = false and salir = false) [bajarPasillo]]

    if salir = true and xcor = 30 [salirTienda] ;Salimos e la tienda

    ifelse random 200 < carga / 10 and contagiado = true [toser]
    [if random 100 < 3 and contagiado = true [respirar]]
  ]



  ; Cambiamos los atributos de todo aquel que sale de la tienda
  ask personas with [pcolor = blue and comprando = true] [;Controla cuando la gente salen de la tiemda
    set comprando false
    setxy ((random 8) + 62) random 25
    set aforoActual aforoActual - 1
    set posLista 6 - TiempoCompra ;inicializamos la lista para la siguiente compra
    set Pasillo item posLista lista
    facexy 0 ycor
    set subiendo true
    set salir false
  ]

  ;virus

  ask virus  [

    compute-forces
    apply-forces
  ]
 tick;
 set tickdia tickdia + 1
end


to moverIzquierda

  let x Pasillo
  facexy x ycor ; miro a donde me voy a mover
  setxy xcor - 1 ycor ; me muevo

end

to moverDerecha

  let x Pasillo
  facexy x ycor ; miro a donde me voy a mover
  setxy xcor + 1 ycor; me muevo

end

to subirPasillo
  set size 3
  facexy xcor 55 ; miro a donde me voy a mover
  setxy xcor ycor + 1; me muevo

  if random 100 <= 2 [
    let xn 0
    let yn 0
    let cargaPegada 0
    let c contagiado
    let cargaC carga
    ask neighbors4 with [pcolor = brown or pcolor = red]
    [
     set xn pxcor
      set yn pxcor
      ifelse c = true [set cargaEstantes cargaEstantes + cargaC];si esta infectado le pega al estante su carga
      [set cargaPegada cargaEstantes] ;si no esta infectado guardamos la carga del estante

    ]
    if guantesPuestos = false[set carga carga + cargaPegada]; si no lleva guantes pilla la carga que tenia el estante

    if xn != 0 or yn != 0 [ set size 5 facexy xn yn]
  ]

  if ycor > 55 and posLista < 5 [ ; menor que 5 porque hay 6 elementos y se aumenta dentro
    set subiendo false
    set posLista posLista + 1
    set Pasillo item posLista lista
  ]

  if ycor > 55 and posLista > 5 [;cuando queremos salir
   set salir true
   set Pasillo 30
   set subiendo false
  ]


end

to bajarPasillo
  set size 3
  facexy xcor 4 ; miro a donde me voy a mover
  setxy xcor ycor - 1; me muevo

  if random 100 <= 10 [
    let xn 0
    let yn 0
   let cargaPegada 0
    let c contagiado
    let cargaC carga
    ask neighbors4 with [pcolor = brown or pcolor = red]
    [
     set xn pxcor
      set yn pxcor
      ifelse c = true [set cargaEstantes cargaEstantes + cargaC];si esta infectado le pega al estante su carga
      [set cargaPegada cargaEstantes] ;si no esta infectado guardamos la carga del estante

    ]
    if guantesPuestos = false[set carga carga + cargaPegada]; si no lleva guantes pilla la carga que tenia el estante

    if xn != 0 or yn != 0 [ set size 5 facexy xn yn]
  ]

  if ycor < 4 and posLista < 5 [
    set subiendo true
    set posLista posLista + 1
    set Pasillo item posLista lista
  ]

  if ycor < 4 and posLista >= 5 [;cuando queremos salir
   set salir true
   set Pasillo 30
   set subiendo false
  ]

end

to salirTienda ;vamos a la puerta
  if ycor > 0 [
  facexy xcor 0 ; miro a donde me voy a mover
  setxy xcor ycor - 1; me muevo

  ]
end

to toser
    if(mascarilla = false) [;si lleva mascarilla no contagia
    hatch-virus numParticulas [
    set color violet
    set label ""
    set vida 200
    set size 0.5
      set velocity-x 8 - (random-float 10) ; initial x velocity
      set velocity-y 8 - (random-float 10) ; initial y velocity
    ]
    ]
end


to respirar
    if(mascarilla = false) [; si lleva mascarilla no contagia
    hatch-virus numParticulas * 0.66 [
    set color violet
    set label ""
    set vida 500
    set size 0.5
      set velocity-x 6 - (random-float 8) ; initial x velocity
      set velocity-y 6 - (random-float 8) ; initial y velocity
    ]
    ]
end

to compute-forces
  ask virus
  [
    ; clear force accumulators
    set force-accumulator-x 0
    set force-accumulator-y 0
    set vida vida - 1
    ; calculate forces
    apply-viento
  ]
end

to apply-forces
  ask virus
  [
    set velocity-x (velocity-x + (force-accumulator-x * step-size)) * 0.95
    set velocity-y (velocity-y + (force-accumulator-y * step-size)) * 0.95
    let step-x velocity-x * step-size
    let step-y velocity-y * step-size
    ; vamos a controlar cuando muere cada particula de virus
    let muere false
    ask patch xcor ycor [if (pcolor = black or pcolor = brown or pcolor = blue)[set muere true ]] ; esto es por si toca algun objeto
    ask patch xcor ycor [if (pcolor = brown)[
      set muere true
      set cargaEstantes  cargaEstantes + 1 ;Le pega la carga al estante
    ]
    ]
    if muere = true [die]
    if vida = 0 [die]
    ;; if the turtle does not go out of bounds
    ;; add the displacement to the current position
    let new-x xcor + step-x
    let new-y ycor + step-y
    facexy new-x new-y
    setxy new-x new-y
  ]
end

to apply-viento  ;; turtle procedure
  set force-accumulator-y force-accumulator-y - viento * 0.1
end

to controlaEstados

  ask personas with [diaEstado = dia and Edad < 19 and contagiado = true and curarse = false];vemos las personas que cambiaron de estado hace 7 dias para cambiarlos de estados y son niños
    [

      ifelse(Contagiado = true and UCI = false)[
        ifelse random 1000  < (item  0 porcentajesNiños) * 10 [ set UCI true     setxy ((random 8) + 62) (random 16) + 28 facexy 0 ycor set diaEstado  dia + 7 + random 5 set Uhoy Uhoy + 1]; pasa a la UCI
        [ifelse random 1000  < (item  1 porcentajesNiños) * 10 [ set muerto true set contagiado false setxy ((random 8) + 62) (random 11) + 48 facexy 0 ycor set diaEstado  dia set Mhoy Mhoy + 1]
          [set curarse  true set diaEstado  dia + 19]; Si no entra en la UCI ni muere pasa a se curaran 19 porque el promedio de curacion esta a los 24 dias desde los sintomas
        ]
      ]
      [if(Contagiado = true and UCI = true); si esta ya en la UCI vemos que le pasa
        [ifelse random 1000  < (item  1 porcentajesNiños) * 10
          [set muerto true set contagiado false setxy ((random 8) + 62) (random 11) + 48 facexy 0 ycor  set UCI false set Mhoy Mhoy + 1 ]
          [set contagiado false set curado true set color green setxy ((random 8) + 62) random 25 facexy 0 ycor set UCI false ]; Si no muere entonces se cura
        ]
      ]
  ]

   ask personas with [diaEstado = dia and Edad >= 19 and Edad < 60 and contagiado = true and curarse = false];vemos las personas que cambiaron de estado hace 7 dias para cambiarlos de estados y son adultos
    [

      ifelse(Contagiado = true and UCI = false)[
        ifelse random 1000  < (item  0 porcentajesAdultos) * 10 [ set UCI true     setxy ((random 8) + 62) (random 16) + 28 facexy 0 ycor set diaEstado  dia + 7 + random 5 set Uhoy Uhoy + 1]; pasa a la UCI
        [ifelse random 1000  < (item  1 porcentajesAdultos) * 10 [ set muerto true set contagiado false setxy ((random 8) + 62) (random 11) + 48 facexy 0 ycor set diaEstado  dia set Mhoy Mhoy + 1]
          [set curarse  true set diaEstado  dia + 20]; Si no entra en la UCI ni muere pasa a se curaran
        ]
      ]
      [if(Contagiado = true and UCI = true); si esta ya en la UCI vemos que le pasa
        [ifelse random 1000  < (item  1 porcentajesAdultos) * 10
          [set muerto true set contagiado false setxy ((random 8) + 62) (random 11) + 48 facexy 0 ycor set diaEstado  dia set UCI false  set Mhoy Mhoy + 1]
          [set contagiado false set curado true set color green setxy ((random 8) + 62) random 25 facexy 0 ycor set diaEstado  dia set UCI false]; Si no muere entonces se cura
        ]
      ]
    ]

   ask personas with [diaEstado = dia and Edad > 60 and contagiado = true and curarse = false];vemos las personas que cambiaron de estado hace 7 dias para cambiarlos de estados y son mayores
    [
      ifelse(Contagiado = true and UCI = false and curarse = false)[
        ifelse random 1000  < (item  0 porcentajesMayores) * 10 [ set UCI true     setxy ((random 8) + 62) (random 18) + 28 facexy 0 ycor set diaEstado  dia + 7 + random 5 set Uhoy Uhoy + 1]; pasa a la UCI
        [ifelse random 1000  < (item  1 porcentajesMayores) * 10 [ set muerto true set contagiado false setxy ((random 8) + 62) (random 13) + 48 facexy 0 ycor set diaEstado  dia set Mhoy Mhoy + 1]
          [set curarse  true set diaEstado  dia + 20]; Si no entra en la UCI ni muere pasa a se curaran
        ]
      ]
      [if(Contagiado = true and UCI = true); si esta ya en la UCI vemos que le pasa
        [ifelse random 1000  < (item  1 porcentajesMayores) * 10
          [set muerto true set contagiado false setxy ((random 8) + 62) (random 13) + 48 facexy 0 ycor set diaEstado  dia set UCI false set Mhoy Mhoy + 1]
          [set contagiado false set curado true set color green setxy ((random 8) + 62) random 25 facexy 0 ycor set diaEstado  dia set UCI false]; Si no muere entonces se cura
        ]
      ]
  ]


ask personas with [diaEstado = dia and curarse = true and contagiado = true][;Las personas que pasan los dias de incubacion y los 20 del virus, se van curando
    set contagiado false set curado true set color green setxy ((random 8) + 62) random 25 facexy 0 ycor set UCI false
    set Curahoy Curahoy + 1
  ]


end




















@#$#@#$#@
GRAPHICS-WINDOW
212
10
756
479
-1
-1
7.55
1
10
1
1
1
0
0
0
1
0
70
0
60
0
0
1
ticks
30.0

BUTTON
5
10
68
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
10
175
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
106
179
139
AforoMax
AforoMax
0
100
14.0
1
1
NIL
HORIZONTAL

SLIDER
7
150
179
183
Mascarillas
Mascarillas
0
100
20.0
5
1
%
HORIZONTAL

SLIDER
6
198
178
231
Guantes
Guantes
0
100
20.0
5
1
%
HORIZONTAL

SLIDER
0
243
186
276
Contagiados_Iniciales
Contagiados_Iniciales
1
100
16.0
1
1
%
HORIZONTAL

SLIDER
6
379
178
412
viento
viento
-10
10
0.0
2
1
NIL
HORIZONTAL

SLIDER
7
419
179
452
step-size
step-size
0.0001
0.1
0.0281
0.0005
1
NIL
HORIZONTAL

SLIDER
6
460
178
493
numParticulas
numParticulas
10
100
25.0
5
1
NIL
HORIZONTAL

SLIDER
6
288
178
321
TiempoCompra
TiempoCompra
2
6
2.0
2
1
NIL
HORIZONTAL

SLIDER
5
57
177
90
AnchuraPasillos
AnchuraPasillos
2
6
6.0
1
1
NIL
HORIZONTAL

MONITOR
29
556
111
601
Contagiados
count personas with [contagiado = true]
17
1
11

MONITOR
6
499
64
544
muertos
count personas with [muerto = true]
17
1
11

MONITOR
81
500
138
545
UCI
count personas with [UCI = true]
17
1
11

PLOT
768
10
1072
243
Grafica por el tiempo
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"contagiados" 1.0 0 -2674135 true "" "plot count personas with[ Contagiado = true]"
"pen-1" 1.0 0 -14439633 true "" "plot count personas with[ muerto = true]"
"pen-2" 1.0 0 -13345367 true "" "plot count personas with[ UCI = true]"

SLIDER
5
335
177
368
Poblacion
Poblacion
100
2000
500.0
200
1
NIL
HORIZONTAL

PLOT
761
270
1079
462
Grafica dia
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -2674135 true "" "plot Choy"
"pen-1" 1.0 0 -14439633 true "" "plot Mhoy"
"pen-2" 1.0 0 -13345367 true "" "plot Uhoy"
"pen-3" 1.0 0 -16777216 true "" "plot Curahoy"

PLOT
187
484
367
604
Contagiados por dia
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Choy"

PLOT
373
484
573
604
Muertos por dia
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Mhoy"

PLOT
579
485
779
605
UCI por dia
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Uhoy"

TEXTBOX
782
249
932
267
Curados
11
0.0
1

TEXTBOX
829
250
869
268
Muertos
11
65.0
1

TEXTBOX
875
250
1025
268
Contagiados
11
15.0
1

TEXTBOX
945
251
1095
269
UCI
11
95.0
1

MONITOR
878
486
960
531
Mayores UCi
count personas with [UCI = true and edad > 60]
17
1
11

MONITOR
968
486
1035
531
Niños UCI
count personas with [UCI = true and edad < 19]
17
1
11

MONITOR
793
485
872
530
Adultos UCI
count personas with [UCI = true and edad < 61 and edad > 18]
17
1
11

MONITOR
878
543
961
588
RIP Mayores
count personas with [Muerto = true and edad > 60]
17
1
11

MONITOR
793
544
871
589
RIP Adultos
count personas with [Muerto = true and edad < 61 and edad > 18]
17
1
11

MONITOR
970
543
1036
588
RIP Niños
count personas with [Muerto = true and edad < 18]
17
1
11

@#$#@#$#@
## WHAT IS IT?

Esto es una simulación de cómo se contagia el virus del SARS-CoV-2, también conocido como coronavirus, dentro de un supermercado, y como le afecta a la población a lo largo del tiempo.

## COMO FUNCIONA (HOW IT WORKS)

Vamos a tener una población fija, la cual va a tener un número de infectados por el virus. En el supermercado los contagiados van a ir respirando y tosiendo, y si no tienen mascarillas, van a ir soltando partículas del virus. A su vez estos infectados también van a ir tocando las estanterías a las cueles les va a trasmitir su carga vírica. Los agentes que no están infectados van a ir con normalidad al supermercado y si se recogen las suficientes partículas de virus se van a infectar. La única protección que tienen los que no están infectados, son los guantes para no coger la carga vírica que tiene las estanterías. Una vez un infectado se haya curado, este se pondrá en verde y tendrá suficientes anticuerpos para no contagiarse de nuevo.

## COMO USARLO (HOW TO USE IT)

Antes de darle al botón de "setup", podemos elegir los valores de:

	-AnchuraPasillos: Es la distancia que hay entre cada estantería.
	-Mascarillas: Porcentaje de la población que llevara mascarilla.
	-Guantes: Porcentaje de la población que llevara guantes.
	-Contagiados_Iniciales: Porcentaje de contagiados al empezar la ejecución.
	-Poblacion: Numero de avatares que vamos a utilizar en la ejecución.

Una vez pulsado el botón de "setup", tenemos que pulsar el botón de "go" para empezar la ejecución.

Durante la ejecucion, podemos modificar:

	-AforoMax: Es el aforo máximo permitido.
	-TiempoCompra: Es el número de pasillos que va a visitar el agente antes de irse
	-Viento: Aire acondicionado de la tienda, mueve las partículas del virus.
	-step-size: Varia la dispersión de las partículas.
	-numParticulas: Numero de partículas que suelta cada agente.

## COSAS QUE NOTAR (THINGS TO NOTICE)

Los agentes que están comprando, van a interactuar con las estanterías de su alrededor. Para notar que están comprando, por un momento se ponen más grande de su tamaño y miran a la estantería.

## QUE PROBAR

Distintos escenarios que se pueden probar pueden ser:

Caso 1: En este caso hemos tomado la estrategia de no hacer ningún cambio ni imponer leyes para mejorar la situación. El supermercado tiene un aforo máximo permanente de 14 personas, los más precavidos utilizan guantes o mascarillas, por lo que es un porcentaje muy bajo de la población (25%). Se ha utilizado un supermercado con pasillos anchos (6), para incentivar a la distancia de seguridad y dificultar la expansión del virus. Se empieza con un 25% de la poblacion contagiada y una poblacion total de 500.

Caso 2:Este caso es similar al caso anterior, con la diferencia de que en mitad de la expansión del virus hemos tomado la medida de limitar el aforo del supermercado a la mitad de su aforo máximo (El aforo enpieza en 14 y pasa a 7). Los demas parametros no cambian respecto al caso anterior.

Caso 3:En esta simulación nos hemos adentrado un poco más en la etapa de contagios donde ya está infectada el 53% de la población. La ejecución comprueba como hubiera sido que, con este porcentaje de infectados, el gobierno simplemente recomendara la medida aconsejar la utilización de guantes y mascarillas. Teniendo en cuenta que es solo una recomendación hemos puesto que solo un 55% de la población utiliza estos medios de protección. El aforo se mantiene en 14, la anchura de los pasillos en 6 y la poblacion total en 500.

Caso 4: En esta ejecución vamos a tener en cuenta el escenario del caso 3, donde ya hay un 53% de la población contagiada, pero con la diferencia que el gobierno impondría la utilización de guantes y mascarillas obligatorios. Teniendo en cuenta a los más irresponsables, no toda la población va a llevar estos medios de protección, pero la gran mayoría sí los utiliza (el 90% utiliza guantes y mascarillas). Todos los demas datos se mantienen como en el caso 3.

## AMPLIACION DEL MODELO (EXTENDING THE MODEL)

Se puede añadir una lista de la compra para que sea mas realista, también se puede incorporar cajeros y una cola para pagar en ellos. Otra mejora posible seria la incorporación de un hospital.

## CARACTERISTICAS DE NETLOGO (NETLOGO FEATURES)

La población se crea al principio y no varía durante la ejecución. Se crea siguiendo la población española donde un 15% son niños, un 19% son ancianos y el resto son adultos.

Para que una persona se contagie, tiene que pasar por la nube de partículas de virus provocada por la tos o la respiración de un contagiado. Esto si el contagiado no lleva mascarilla, si la llevara, este no suerte partículas del virus. Otra manera de contagiarse es cuando un contagiado toca un estante y una persona sana lo toca sin guantes, lo que provoca que coja la carga vírica del estante.

La grafica de acumulados va a contar en cada tick cada uno de los estados (muertos, UCI y contagiados) y los va a ir pintando en ella. Estas variables se van a cambiar en el momento que cada agente pase de estado. Una persona sana cuando acumula suficiente carga vírica pasa a estar contagiado, mientras que un contagiado cuando pasa el periodo de incubación y unos días en lo que los síntomas se agravan, puede ir a la UCI, aunque sigue estando contagiado. Si los síntomas se agravan y no puede ir a la UCI, la persona muere o en su contra, según la revista Gaceta Médica, si los síntomas son leves, los agentes se curan al pasar 24 días de sus primeros síntomas pasando al estado de curado.
Una persona en la UCI puede empeorar y morir de 7 a 11 días, como afirma una entrevista realizada a Félix M, medico de Madrid, por la Vanguardia, o puede recuperarse y pasa al estado de curado donde ya tiene anticuerpos para no contagiarse de nuevo.

Según el rango de edad en el que se encuentre (niño, adulto o mayor), cada persona tiene unas probabilidades de curarse, ir a la UCI, o morir. Estos datos han sido sacados de la gráfica proporcionada por el profesor.

La grafica por días se basa en 4 varíales, que refleja los contagiados, curados, muertos y los que van a la UCI ese mismo día. Una vez termine el día esas variables se reinician a 0.

El día va a contar de 12 h, que son 1200 ticks y según la hora en la que nos encontremos, la afluencia de gente va a ser mayor o mejor según los datos recogidos por Google sobre un Mercadona de Huelva.

Los domingos, el supermercado cierra, por lo que se vacía y se queda cerrado hasta el siguiente día, teniendo en cuenta ese día para las estadísticas de la población contagiada.


## REFERENCIAS (CREDITS AND REFERENCES)

Para generar la dispersión del virus, hemos utilizado la implementación de "Particle System Basic" que se encuentra en la biblioteca de modelos.

También nos hemos basado en los siguientes artículos para poder recolectar toda la información necesaria para la simulación.

Días en la uci
https://www.lavanguardia.com/vida/20200322/4817187506/los-que-van-a-ir-mal-estan-28-dias-en-la-uci-los-que-van-bien-11-hay-que-pensarlo.html

Días de incubación
https://www.dw.com/es/covid-19-cu%C3%A1nto-dura-el-proceso-de-incubaci%C3%B3n/a-52578128

defensa de la mascarilla
https://www.ocu.org/salud/bienestar-prevencion/consejos/mascarillas-prevenir-contagios

cuanto tarda en curarse
https://gacetamedica.com/investigacion/covid-19-cuando-un-paciente-esta-curado/

cómo se contagia
https://www.who.int/es/news-room/commentaries/detail/modes-of-transmission-of-virus-causing-covid-19-implications-for-ipc-precaution-recommendations

carga vírica 
https://www.investigacionyciencia.es/blogs/psicologia-y-neurociencia/95/posts/la-importancia-de-la-carga-viral-en-la-transmisin-gravedad-y-pronstico-de-la-covid-19-18489
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
