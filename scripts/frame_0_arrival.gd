extends Node2D

@onready var player := $WorldLayer/Player

@onready var fade := $UI/RootUI/Fade
@onready var arrival_text := $UI/RootUI/ArrivalText

@onready var dialogue_box := $UI/RootUI/DialogueBox
@onready var npc_text := $UI/RootUI/DialogueBox/NPCText
@onready var choice_a := $UI/RootUI/DialogueBox/ChoicesRow/ChoiceA
@onready var choice_b := $UI/RootUI/DialogueBox/ChoicesRow/ChoiceB

@onready var npc_area := $WorldLayer/NPC_0

var near_npc := false
var in_dialogue := false

func _ready() -> void:
    # --- your existing intro flow ---
    player.can_move = false
    arrival_text.visible = true
    arrival_text.modulate.a = 1.0
    dialogue_box.visible = false

    fade.visible = true
    fade.modulate.a = 1.0

    await get_tree().create_timer(0.4).timeout
    await _fade_alpha(fade, 0.0, 1.4)
    fade.visible = false

    await get_tree().create_timer(1.2).timeout
    player.can_move = true

    # connect npc area signals
    npc_area.body_entered.connect(_on_npc_body_entered)
    npc_area.body_exited.connect(_on_npc_body_exited)

    # connect button presses
    choice_a.pressed.connect(func(): _on_choice_pressed("A"))
    choice_b.pressed.connect(func(): _on_choice_pressed("B"))

func _process(delta: float) -> void:
    if near_npc and not in_dialogue and Input.is_action_just_pressed("ui_accept"):
        _start_dialogue()

func _start_dialogue() -> void:
    in_dialogue = true
    player.can_move = false

    dialogue_box.visible = true
    npc_text.text = "Hey. Before you move on… how are you arriving today?"

    choice_a.text = "Tired."
    choice_b.text = "Nervous, but here."

func _on_choice_pressed(which: String) -> void:
    # Tailored reply, same end result
    if which == "A":
        npc_text.text = "Then we’ll go gently. You don’t have to earn rest."
    else:
        npc_text.text = "That’s honest. Courage can be quiet like that."

    # Hide buttons for a beat, then close
    choice_a.visible = false
    choice_b.visible = false

    # Give reward token (for now just print; later we’ll store in GameState)
    print("REWARD: Token_0")

    await get_tree().create_timer(1.5).timeout
    _end_dialogue()

func _end_dialogue() -> void:
    dialogue_box.visible = false
    choice_a.visible = true
    choice_b.visible = true
    in_dialogue = false
    player.can_move = true

func _on_npc_body_entered(body: Node) -> void:
    if body.name == "Player":
        near_npc = true
        if not in_dialogue:
            arrival_text.text = "Press Enter to talk."

func _on_npc_body_exited(body: Node) -> void:
    if body.name == "Player":
        near_npc = false
        if not in_dialogue:
            arrival_text.text = ""  # or restore your default line

func _fade_alpha(node: CanvasItem, target: float, duration: float) -> void:
    var t := create_tween()
    t.tween_property(node, "modulate:a", target, duration)\
        .set_trans(Tween.TRANS_SINE)\
        .set_ease(Tween.EASE_IN_OUT)
    await t.finished
