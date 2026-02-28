extends CharacterBody2D
class_name Submarine
# Submarine.gd 
# Slouží už POUZE jako controller (pohyb) hráče. Logiku životů a správy
# jsme přesunuli pryč, sem se pouze připojíme na signály dětí.

@export var max_speed: float = 350.0
@export var acceleration: float = 1000.0
@export var water_friction: float = 400.0

@onready var starting_y_position: float = global_position.y

# Očekáváme, že v Editoru pod tuto ponorku přidáme HealthComponent Node.
# V _ready ho napojíme na funkci on_death
@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite: AnimatedSprite2D = $Sprite2D
var inventory: Inventory

func _ready() -> void:
	inventory = Inventory.new()
	add_child(inventory)
	# Přeposlání signálu do globálního GameManageru
	inventory.inventory_changed.connect(func(c, m): GameManager.inventory_capacity_changed.emit(c, m))
	
	if health_component:
		# Takhle se připojuje signál z kódu od verze Godot 4.0
		health_component.died.connect(_on_death)
		
		# Test - Aplikování upgradu z nového GameManagera na base hp
		# Zvýší HP třeba o 50 za každý level trupu nad 1
		health_component.max_hp += (GameManager.hull_level - 1) * 50
		health_component.current_hp = health_component.max_hp

func _physics_process(delta: float) -> void:
	# 1. Spočítat aktuální hloubku a odeslat ji manažerovi
	# Tohle hru nezatíží, GameManager ví, jak reagovat, ale dělá to jen on
	var calculated_depth: float = (global_position.y - starting_y_position) / GameManager.PIXELS_PER_METER
	GameManager.current_depth = calculated_depth

	# 2. Získání vstupu přes sémantické akce (musíme je takto nastavit v Project Settings)
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Rychlost hráče bude modifikovaná podle úrovně motoru a hloubkového speed-bostu
	var base_speed_with_upgrades = max_speed + ((GameManager.engine_level - 1) * 50.0)
	var actual_speed = base_speed_with_upgrades * GameManager.get_speed_multiplier()

	# 3. Fyzika a Animace
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * actual_speed, acceleration * delta)
		sprite.play("movement")
		
		# Převrácení spritu, pokud plujeme doprava (výchozí sprite zřejmě míří doleva)
		if input_vector.x > 0:
			sprite.flip_h = true
		elif input_vector.x < 0:
			sprite.flip_h = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, water_friction * delta)
		sprite.play("default")

	move_and_slide()

# Vypořádání se se smrtí - řekneme Autoload managerovi a ten ať už ukončí ponor jak potřebuje
func _on_death() -> void:
	GameManager.on_player_death()
