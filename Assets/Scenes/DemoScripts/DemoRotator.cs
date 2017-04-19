using UnityEngine;
using System.Collections;

public class DemoRotator: MonoBehaviour{
	[SerializeField] Vector3 axis = new Vector3(0.0f, 1.0f, 0.0f);
	[SerializeField] float speed = 15.0f;
	public float speedMultiplier = 1.0f;

	// Update is called once per frame
	void Update(){
		float delta = Time.deltaTime;
		if ((delta <= 0.0f) || (speedMultiplier == 0.0f))
			return;
		transform.RotateAround(transform.position, axis, speed * delta * speedMultiplier);	
	}
}
