using UnityEngine;
using System.Collections;

public class DemoController: MonoBehaviour{
	[SerializeField] Animator podiumAnimator = null;
	[SerializeField] Animator fanAnimator = null;
	[SerializeField] ParticleSystem normalSmoke = null;
	[SerializeField] ParticleSystem oitSmoke = null;
	[SerializeField] GameObject standardCar = null;
	[SerializeField] GameObject standardUnlitCar = null;
	[SerializeField] GameObject oitCar= null;
	[SerializeField] GameObject oitLitCar = null;

	void setActive(GameObject obj, bool active){
		if (!obj)
			return;
		obj.SetActive(active);
	}

	void enableAnimator(Animator animator, bool enabled){
		if (!animator)
			return;
		animator.SetBool("enabled", enabled);
	}

	void enableParticles(ParticleSystem ps, bool enabled){
		if (!ps)
			return;
		var e = ps.emission;
		e.enabled = enabled;
		ps.gameObject.SetActive(enabled);
	}

	public void onSmokeTypeChanged(System.Int32 smokeType){
		enableParticles(normalSmoke, smokeType == 2);
		enableParticles(oitSmoke, smokeType == 1);
	}

	public void onCarTypeChanged(System.Int32 carType){
		setActive(oitCar, carType == 0);
		setActive(standardUnlitCar, carType == 1);
		setActive(oitLitCar, carType == 2);
		setActive(standardCar, carType == 3);
	}

	public void onPodiumToggled(System.Boolean toggled){
		enableAnimator(podiumAnimator, toggled);
	}

	public void onFanToggled(System.Boolean toggled){
		enableAnimator(fanAnimator, toggled);
	}

	void Start(){
		onCarTypeChanged(0);
		onSmokeTypeChanged(0);
		onPodiumToggled(true);
		onFanToggled(true);
	}
}
