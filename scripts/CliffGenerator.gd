extends Node2D
class_name CliffGenerator
# Procedurální generátor okrajových útesů.
# Využívá FastNoiseLite pro vytvoření přirozeně "zubatých" okrajů, 
# které jsou ihned převedeny na kolizní polygony a obarveny.

@export var is_right_side: bool = false
@export var base_width: float = 3000.0 # Jak daleko do šířky útes (neviditelně) sahá, zabraňuje vypadnutí
@export var max_y: float = 120000.0 # Dostatečně velká hloubka pro Hloubku 10 000
@export var segment_length: float = 180.0 # Vzdálenost bodů na ose Y. Čím nižší, tím detailnější.
@export var jaggedness: float = 200.0 # Jak moc čouhají zuby do úrovně hráče

@onready var static_body = StaticBody2D.new()
@onready var poly = Polygon2D.new()
@onready var collision = CollisionPolygon2D.new()

func _ready() -> void:
    # Programové sestavení uzlů tak at neplevelíme manuálně scénu
    add_child(static_body)
    add_child(poly)
    static_body.add_child(collision)
    
    # Barva hlubinného kamenného útesu
    poly.color = Color(0.12, 0.15, 0.22) 
    
    generate_cliff()

func generate_cliff() -> void:
    var points := PackedVector2Array()
    var current_y: float = -2000.0 # Započneme už nad hranicí obrazovky, ať nejsou vidět useklé textury
    
    var noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.005
    
    if not is_right_side:
        # ------- LEVÝ ÚTES -------
        points.append(Vector2(-base_width, current_y)) 
        
        while current_y <= max_y:
            # abs() zajistí, že zuby rostou "do mapy", nikoliv ven
            var offset = abs(noise.get_noise_1d(current_y)) * jaggedness
            points.append(Vector2(offset, current_y)) 
            current_y += segment_length
            
        points.append(Vector2(-base_width, max_y)) 
    else:
        # ------- PRAVÝ ÚTES -------
        points.append(Vector2(base_width, current_y)) 
        
        while current_y <= max_y:
            # Přidáme šumovou odchylku (+5000), ať oba útesy nejsou stejné
            var offset = abs(noise.get_noise_1d(current_y + 5000.0)) * jaggedness
            points.append(Vector2(-offset, current_y)) 
            current_y += segment_length
            
        points.append(Vector2(base_width, max_y)) 
        
    poly.polygon = points
    collision.polygon = points
