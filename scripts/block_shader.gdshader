shader_type canvas_item;

uniform sampler2D tile_texture;  // The tile texture (atlas)
uniform vec2 player_position;    // The player's position
uniform float reveal_radius;     // The radius around the player where tiles become visible
uniform vec2 tile_size;          // The size of each tile in the atlas
uniform vec2 atlas_size;         // The size (in tiles) of the texture atlas

void fragment() {
    // Calculate the tile's index in the tilemap (this assumes the tilemap is aligned with the texture grid)
    vec2 tile_coords = floor(FRAGCOORD.xy / tile_size);
    
    // Calculate the UV coordinates for the tile in the texture atlas
    vec2 atlas_uv = tile_coords / atlas_size;
    
    // Sample the texture at the calculated UV
    vec4 tex_color = texture(tile_texture, atlas_uv);
    
    // Calculate the distance from the player to the current tile
    float distance_to_player = length(player_position - FRAGCOORD.xy);
    
    // Calculate visibility based on distance (smoothstep ensures smooth fading)
    float visibility = smoothstep(reveal_radius, reveal_radius + 10.0, distance_to_player);
    
    // Apply the visibility factor to the texture color
    tex_color.rgb *= visibility;  // Apply visibility to the texture's color
    tex_color.a *= visibility;    // Apply visibility to the alpha channel (opacity)
    
    // Set the final color of the tile
    COLOR = tex_color;
}