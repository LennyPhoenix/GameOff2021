shader_type canvas_item;

uniform float modulate;


float rand(vec2 input){
    return fract(sin(dot(input, vec2(12.9898, 78.233))) * 43758.5453);
}


void fragment()
{
	if (AT_LIGHT_PASS)
	{
		vec4 tex_colour = texture(TEXTURE, UV);
		
		float noise = rand(FRAGCOORD.xy + TIME);
		tex_colour.a *= noise * modulate;

		COLOR = tex_colour;
	}
	else
	{
		COLOR = vec4(0);
	}
}
