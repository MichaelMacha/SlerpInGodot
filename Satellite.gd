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
		
		## Classic lerp
		#var new_pos = lerp(start_point, target_point, t)
		
		## Classic slerp
		#var new_pos = slerp(start_point, target_point, t)
		
		## Newfangled "flerp" — or /function/ linear interpolation, for a sphere
		#var new_pos = flerp(start_point, target_point, \
			#func(f : float, n : float):
				#return sin(f * n)/sin(n)
				#,
			#t,
			#acos(start_point.normalized().dot(target_point.normalized()))
			#)
			
		var new_pos = flerp(start_point, target_point, \
			func(f : float, n : float):
				return (1.0 + 0.5 * sin(f * PI)) * sin(f * n)/sin(n)
				,
			t,
			acos(start_point.normalized().dot(target_point.normalized()))
			)
		print(new_pos)
		self.global_position = new_pos

# Ye Olde Slerp
func slerp(p0 : Vector3, p1 : Vector3, t_ : float) -> Vector3:
	var omega := acos(p0.normalized().dot(p1.normalized()))
	
	return \
		(sin((1.0 - t_) * omega) * p0 + \
		sin(t_ * omega) * p1) \
		/ sin(omega)

# For flerp, f should take a floating point progress value and a normalization 
# to divide by. It should be constrained so that it is always at p0 at t_ == 0,
# and p1 at t_ == 1; but it can behave as it pleases between the two. Otherwise,
# you will get a nonsensical and often unusable result.
func flerp(p0 : Vector3, p1 : Vector3, f : Callable, t_ : float, n : float) -> Vector3:
	return \
		f.call((1.0 - t_), n) * p0 + \
		f.call(t_, n) * p1
