extends KinematicBody2D

#stale ruchu
const predkosc_max = 0.5
const przyspieszenie = 10
const tarcie = 10

#staty
onready var zycie = zycie_max setget zmiana_zycie
export var zycie_max = 10
export var zycie_reg = 1
var odbicie = Vector2.ZERO


var rng = RandomNumberGenerator.new()



var stan = spawn
var predkosc = Vector2.ZERO
var pozycja_gracza
var czas = false
var odleglosc = 10



onready var animacja_gracz = $AnimationPlayer
onready var animacja_tree = $AnimationTree
onready var tekstura = $ObcyTekstura
onready var reka_lewa = $RekaLewa
onready var reka_prawa = $RekaPrawa
onready var animacja_status = animacja_tree.get("parameters/playback")
onready var player = get_tree().root.get_node("Swiat/GraczPostac")
onready var kierunek = Vector2.ZERO


enum {
	idz,
	spawn,
	smierc
	
}


func _ready():
	animacja_tree.active = true	
	rng.randomize()
	
#func _process(delta):
# Reg HP za szybkie
#	zycie = min(zycie + zycie_reg * delta, zycie_max)
	
	
	
	
	
func zmiana_zycie(value):
	zycie -= value
	
func _physics_process(delta):
	
	
#tablica switch:
	match stan:
		idz:
			ruch(delta)
		spawn:
			spawn()
		smierc:
			smierc(delta)
		

func ruch(delta):
	tekstura.visible = true
	reka_lewa.visible = true
	reka_prawa.visible = true
	
	pozycja_gracza = player.position - position
	
	odbicie = odbicie.move_toward(Vector2.ZERO, 120 * delta)
	odbicie = move_and_slide(odbicie)
#losowanie chodzenia, zrobic dystans i ograniczyc teren
	if pozycja_gracza.length() > 130 and czas == true :
		var random_number = rng.randf()
		if random_number <= 0.09:
			print(random_number)
			predkosc = predkosc.move_toward(Vector2.ZERO, tarcie * delta)
		#	animacja_tree.set("parameters/Stoj/blend_position", pozycja_gracza)
			animacja_status.travel("Stoj")
			
		if random_number < 0.1 and random_number > 0.09:
			kierunek = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			animacja_tree.set("parameters/Ruch/blend_position", kierunek)
			kierunek.normalized()
			predkosc = predkosc.move_toward(kierunek * random_number, przyspieszenie * delta)
			animacja_status.travel("Ruch")
			move_and_collide(kierunek)
			print(random_number)
			
		czas = false
	
	
	if pozycja_gracza.length() > 100 and pozycja_gracza.length() < 130 :
		animacja_tree.set("parameters/Stoj/blend_position", pozycja_gracza)
		animacja_status.travel("Stoj")
		predkosc = predkosc.move_toward(Vector2.ZERO, tarcie * delta)
		
		
	if pozycja_gracza.length() == 100 :
		animacja_tree.set("parameters/Ostrzegaj/blend_position", pozycja_gracza)
		animacja_status.travel("Ostrzegaj")
		
		
		
	if pozycja_gracza.length() < 100 :
		animacja_tree.set("parameters/Ruch/blend_position", pozycja_gracza)
		kierunek = pozycja_gracza.normalized()
		predkosc = predkosc.move_toward(kierunek * predkosc_max, przyspieszenie * delta)
		animacja_status.travel("Ruch")
		
		
		
	if pozycja_gracza.length() < 20 :
		predkosc = predkosc.move_toward(Vector2.ZERO, tarcie * delta)
		animacja_tree.set("parameters/Atak/blend_position", pozycja_gracza)	
		animacja_status.travel("Atak")
		
	move_and_collide(predkosc)
	
	
func atak_koniec():
	stan = idz


func _on_HurtBox_area_entered(area):
	var obrazenia = player.obrazenia_bohater
	odbicie = area.odbicie_kierunek * 120
	zmiana_zycie(obrazenia)	
	if zycie > 0:
#co sie dzieje podczas uderzenia od bohatera
		print(zycie)
	else: stan = smierc
	


func _on_Timer_timeout():
	czas = true

func spawn():
	tekstura.visible = false
	reka_lewa.visible = false
	reka_prawa.visible = false
	
	animacja_gracz.play("spawn")

	
func spawn_koniec():
	stan = idz
	
func smierc(delta):
	predkosc = Vector2.ZERO
	odbicie = Vector2.ZERO
	tekstura.visible = false
	reka_lewa.visible = false
	reka_prawa.visible = false
	animacja_status.travel("Smierc")
	animacja_gracz.play("Smierc")
	
