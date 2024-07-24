class_name Satellite extends CharacterBody3D

# Strategy: Satellite should interpolate along slerp between two points.
var t = 0.0
@onready var start_point := self.global_position

## target_point is our destination. Since Vector3's can't sensibly be null,
## Vector3.ZERO equates to false; we will use this as it's also a garbage value
## and literally the center of the planet. When no target is set, target_point
## is just zero.
var target_point : Vector3:
	set(value):
		target_point = value
		
		#Also reset start_point to the current position and t to zero
		start_point = self.global_position
		t = 0.0
		
		#If we don't reset these, we'll get a discontinuity in the movement.

func _process(delta : float) -> void:
	#If we have a valid target point. Remember, invalid is simply Vector3.ZERO,
	#which evaluates to false in a boolean context.
	if target_point:
		#Increment our progress between the two points.
		t += delta
		
		#If we've reached our target (at t = 1.0 in the interpolation)
		if t >= 1.0:
			#Set t back to zero
			t = 0.0
			#Set our start point, at zero, to the target point
			start_point = target_point
			#Invalidate our target point by setting it to zero until we have 
			#a new one.
			target_point = Vector3.ZERO
		
		#In all cases, set our global position to the slerp between start and
		#target points, which is what the above code is enforcing with the
		#parameters.
		self.global_position = slerp(start_point, target_point, t)

# Ye Olde Slerp
func slerp(p0 : Vector3, p1 : Vector3, t_ : float) -> Vector3:
	var omega := acos(p0.normalized().dot(p1.normalized()))
	
	return \
		(sin((1.0 - t_) * omega) * p0 + \
		sin(t_ * omega) * p1) \
		/ sin(omega)
