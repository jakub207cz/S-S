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
            # 1. Zjistíme, v jakém "tieru" (každých 5000 pixelů = 500 m herní hloubky) jsme
            var depth_tier = int(maxf(0.0, current_y) / 5000.0)
            
            # 2. Útes se v každém tieru přiblíží ke středu o 30 pixelů (zužování)
            var narrowing = depth_tier * 30.0
            
            # 3. Zubatost se v každém tieru mírně zvýší (nebezpečnější výčnělky)
            var current_jaggedness = jaggedness + (depth_tier * 20.0)
            
            var offset = abs(noise.get_noise_1d(current_y)) * current_jaggedness + narrowing
            points.append(Vector2(offset, current_y)) 
            current_y += segment_length
            
        points.append(Vector2(-base_width, max_y)) 
    else:
        # ------- PRAVÝ ÚTES -------
        points.append(Vector2(base_width, current_y)) 
        
        while current_y <= max_y:
            # Identická logika pro pravou stranu
            var depth_tier = int(maxf(0.0, current_y) / 5000.0)
            var narrowing = depth_tier * 30.0
            var current_jaggedness = jaggedness + (depth_tier * 20.0)
            
            # Přidáme šumovou odchylku (+5000), ať oba útesy nejsou identicky zrcadlové
            var offset = abs(noise.get_noise_1d(current_y + 5000.0)) * current_jaggedness + narrowing
            points.append(Vector2(-offset, current_y)) 
            current_y += segment_length
            
        points.append(Vector2(base_width, max_y)) 
        
    poly.polygon = points
    collision.polygon = points
