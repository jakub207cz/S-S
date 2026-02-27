extends CanvasLayer
class_name PlayerUI
# PlayerUI.gd
# Pouze pasivně poslouchá GameManager a HealthComponent ponorky.
# Neobsahuje žádnou logiku hry, jen ukazuje čísla na obrazovku.

# Očekáváme napojení Label uzlů přes Inspector v Editoru
@export var depth_label: Label
@export var materials_label: Label
@export var hp_label: Label

# Volitelně HealthComponent hráče - připojíme manuálně ve hře nebo v _ready získáme od hráče
var player_health: HealthComponent

func _ready() -> void:
    # Reagujeme na signály z roota hry
    GameManager.depth_changed.connect(_on_depth_changed)
    GameManager.materials_changed.connect(_on_materials_changed)
    
    # Prvotní zobrazení
    _on_depth_changed(GameManager.current_depth)
    _on_materials_changed(GameManager.collected_materials)

func setup_health_connection(health_comp: HealthComponent) -> void:
    player_health = health_comp
    player_health.hp_changed.connect(_on_hp_changed)
    
    # První zapsání HP
    _on_hp_changed(player_health.current_hp, player_health.max_hp)

# Callbacky signálů - aktualizují text v Labels
func _on_depth_changed(new_depth: float) -> void:
    if depth_label:
        depth_label.text = "Hloubka: %dm" % int(new_depth)

func _on_materials_changed(new_amount: int) -> void:
    if materials_label:
        materials_label.text = "Loot: %d" % new_amount
        
func _on_hp_changed(current_hp: int, max_hp: int) -> void:
    if hp_label:
        hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
