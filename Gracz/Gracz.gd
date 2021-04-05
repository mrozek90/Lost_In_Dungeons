extends KinematicBody2D

const predkosc_max = 1
const przyspieszenie = 10
const tarcie = 10

#staty gracza
var zycie = 100
var zycie_max = 100
var zycie_reg = 1
var mana = 100
var mana_max = 100
var mana_reg = 2
var czas_ataku = 1000
var czas_kolejnego_ataku = 0
var obrazenia_bohater = 0
var predkosc = Vector2.ZERO
var stan = idz 

onready var wartosc_miecza = $RekaPrawa/Miecz/Miecz
onready var odbicie_kierunek = $RekaPrawa/Miecz/Miecz/HitBox
onready var animacja_gracz = $AnimationPlayer
onready var animacja_tree = $AnimationTree
onready var animacja_status = animacja_tree.get("parameters/playback")


enum {
	idz,
	atak
}


func _ready():
	animacja_tree.active = true


func _physics_process(delta):
	
#tablica switch:
	match stan:
		idz:
			ruch_gracza(delta)
		atak:
			atak_gracza(delta)
			
			
#ruch z klawiszy 
func ruch_gracza(delta):
	var kierunek = Vector2.ZERO
	
	kierunek.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	kierunek.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	kierunek = kierunek.normalized() 
#dzialania podczas ruchu
	if kierunek != Vector2.ZERO:
		#odbicie miecza
		odbicie_kierunek.odbicie_kierunek = kierunek
		#
		animacja_tree.set("parameters/Ruch/blend_position", kierunek)
		animacja_tree.set("parameters/Stoj/blend_position", kierunek)
		animacja_tree.set("parameters/Atak/blend_position", kierunek)
		animacja_status.travel("Ruch")
		predkosc = predkosc.move_toward(kierunek * predkosc_max, przyspieszenie * delta)
		
#dzialania podczas stania 
	else: 
		predkosc = predkosc.move_toward(Vector2.ZERO, tarcie * delta)
		animacja_status.travel("Stoj")
		
	move_and_collide(predkosc)
	
	if Input.is_action_pressed("ui_atack"):
		stan = atak
	

#atak
func atak_gracza(delta):
	predkosc = Vector2.ZERO
	
	var teraz = OS.get_ticks_msec()
	if teraz >= czas_kolejnego_ataku:
		animacja_status.travel("Atak")
		obrazenia_bohater = wartosc_miecza.damage		
		czas_kolejnego_ataku = teraz + czas_ataku
		
		
	
	
func atak_koniec():
	stan = idz


func _on_HurtBox_area_entered(area):
	pass # Replace with function body.
