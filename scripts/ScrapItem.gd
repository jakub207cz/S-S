extends Area2D
class_name ScrapItem
# Scrap.gd
# Peníze/Loot, který padne z monstra. Zajišťuje, aby se dalo posbírat hráčem 
# přes dotyk (Area2D kolize) a přidalo se rovnou do GameManagera.

@export var value: int = 1

func _ready() -> void:
    # Ujistíme se, že umíme reagovat na překryv s tělesy (body_entered)
    self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    # Pokud je těleso, které se dotklo lootu naše ponorka (přes class_name)
    if body is Submarine:
        # Přidáme rovnou aktuálnímu hráči materiál
        GameManager.collected_materials += value
        
        # Odeslat drobnou vizuální odezvu (např. animaci, pak se smazat)
        queue_free()
