import re

with open("Office.gd", "r") as f:
    content = f.read()

# Replace _create_btn_style definition
content = re.sub(
    r"func _create_btn_style\(bg_color: Color\) -> StyleBoxFlat:[\s\S]*?return style",
    """func _create_btn_style(bg_color: Color, border_color: Color, bottom_thick: int, top_thick: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = top_thick
	style.border_width_right = 2
	style.border_width_bottom = bottom_thick
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style""",
    content
)

# Replace style building block
content = re.sub(
    r"# Build styles[\s\S]*?# Restore active tab index",
    """# Build styles
	style_normal = _create_btn_style(Color(0.1, 0.2, 0.4, 0.9), Color(0.05, 0.1, 0.2, 0.9), 8, 2)
	style_hover = _create_btn_style(Color(0.15, 0.3, 0.5, 0.95), Color(0.4, 0.6, 0.9, 0.9), 8, 2)
	style_pressed = _create_btn_style(Color(0.05, 0.15, 0.3, 0.9), Color(0.02, 0.08, 0.15, 0.9), 2, 6)
	
	style_tab_active = _create_btn_style(Color(0.15, 0.3, 0.5, 0.95), Color(0.4, 0.6, 0.9, 0.9), 8, 2)
	style_tab_inactive = _create_btn_style(Color(0.08, 0.15, 0.25, 0.9), Color(0.04, 0.08, 0.15, 0.9), 4, 2)
	
	style_gold_normal = _create_btn_style(Color(0.85, 0.65, 0.13, 0.9), Color(0.6, 0.4, 0.05, 0.9), 8, 2)
	style_gold_hover = _create_btn_style(Color(1.0, 0.8, 0.2, 0.95), Color(0.8, 0.6, 0.1, 0.9), 8, 2)
	style_gold_pressed = _create_btn_style(Color(0.65, 0.45, 0.05, 0.9), Color(0.4, 0.2, 0.02, 0.9), 2, 6)
	
	# Restore active tab index""",
    content
)

# Replace sizes in dynamic buttons
content = content.replace('custom_minimum_size = Vector2(160, 45)', 'custom_minimum_size = Vector2(250, 60)')
content = content.replace('custom_minimum_size = Vector2(160, 40)', 'custom_minimum_size = Vector2(250, 60)')
content = content.replace('custom_minimum_size = Vector2(180, 45)', 'custom_minimum_size = Vector2(250, 60)')

content = content.replace('font_size", 16)', 'font_size", 24)')
content = content.replace('font_size", 14)', 'font_size", 22)')
content = content.replace('font_size", 13)', 'font_size", 20)')
content = content.replace('font_size", 12)', 'font_size", 18)')
content = content.replace('font_size", 11)', 'font_size", 16)')

with open("Office.gd", "w") as f:
    f.write(content)
