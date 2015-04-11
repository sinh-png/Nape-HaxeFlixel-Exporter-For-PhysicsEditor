package;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.shape.Circle;
import nape.geom.Vec2;

import flixel.addons.nape.FlxNapeSprite;
{% if global.v4 %}import flixel.addons.nape.FlxNapeSpace;{% else %}import flixel.addons.nape.FlxNapeState;{% endif %}

{% if global.v4 %}import flixel.system.FlxAssets.FlxGraphicAsset;{% endif %}

class {{global.class_name}} {
	
	inline static function _applyBody(X:Null<Float>, Y:Null<Float>, Sprite:FlxNapeSprite, Graphic:{% if global.v4 %}FlxGraphicAsset{% else %}Dynamic{% endif %}, AntiAliasing:Bool, PhysicsBody:Body, BodyMaterial:Material):FlxNapeSprite {
		Sprite = Sprite == null ? new FlxNapeSprite(0, 0, false) : Sprite;
		if (Graphic != null) Sprite.loadGraphic(Graphic);
		Sprite.antialiasing = AntiAliasing;
			
		PhysicsBody.translateShapes(Vec2.weak( -Sprite.origin.x, Sprite.origin.y));
		if (X != null) PhysicsBody.position.x = X;
		if (Y != null) PhysicsBody.position.y = Y;
		if (BodyMaterial != null) PhysicsBody.setShapeMaterials(BodyMaterial);
		
		if (Sprite.body != null) {
			PhysicsBody.space = Sprite.body.space;
			Sprite.destroyPhysObjects();
		}else PhysicsBody.space = {% if global.v4 %}FlxNapeSpace{% else %}FlxNapeState{% endif %}.space;
		
		Sprite.body = PhysicsBody;
		
		return Sprite;
	}
	{% for body in bodies %}
	public static function {{body.label}}(?X:Null<Float>, ?Y:Null<Float>, ?Sprite:FlxNapeSprite, ?Graphic:{% if global.v4 %}FlxGraphicAsset{% else %}Dynamic{% endif %}, ?AntiAliasing:Bool = true, ?BodyMaterial:Material, ?PhysicsBodyType:BodyType):FlxNapeSprite {
		var body = new Body(PhysicsBodyType == null ? BodyType.{{body.type}} : PhysicsBodyType);
		
		{% for fixture in body.fixtures %}{% if fixture.isCircle %}new Circle({{fixture.radius}}, Vec2.weak({{fixture.center.x}}, {{fixture.center.y}})).body = body;
		{% else %}{% for polygon in fixture.polygons %}new Polygon([{% for point in polygon %}{% if not forloop.first %}, {% endif %}Vec2.weak({{point.x}}, {{point.y}}){% endfor %}]).body = body;
		{% endfor %}{% endif %}{% endfor %}
		return _applyBody(X, Y, Sprite, Graphic == null ? {{body.graphic}} : Graphic, AntiAliasing, body, BodyMaterial);
	}
	{% endfor %}
}
