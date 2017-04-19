struct TrFrag{
	float4 c1: COLOR1;
	float4 c2: COLOR2;
};


float computeWeight(float4 color, float z){
	float weight =  
		max(min(1.0, max(max(color.r, color.g), color.b) * color.a), color.a) *
		clamp(0.03 / (0.00001 + pow(z / 200, 4.0)), 0.01, 3000);
	return weight;
}


TrFrag encodeTransparency(float4 col, float z){
//	float weight = computeWeight(color, z); 

	float weight = computeWeight(col, z);
	float4 weightColor = float4(col.xyz, 1.0)*weight;
	float4 weightPremulColor = weightColor*col.w;
	float alpha = col.w;

	TrFrag res;

	res.c1 = float4(weightPremulColor.xyz, 1.0);
	res.c2 = 0.0;
	res.c2.yz = weightPremulColor.w;
	res.c2.w = alpha;

	return res;
}

TrFrag encodeTransparencyAdditive(float4 col, float z, float nonAdditiveFactor){
//	float weight = computeWeight(color, z); 

	float weight = computeWeight(col, z);
	float4 weightColor = float4(col.xyz, 1.0)*weight;
	float4 weightPremulColor = weightColor*col.w;
	float alpha = col.w;

	TrFrag res;

	res.c1 = float4(weightPremulColor.xyz, 1.0);
	res.c2 = 0.0;
	res.c2.yz = weightPremulColor.w * nonAdditiveFactor;
	res.c2.w = alpha * nonAdditiveFactor;

	return res;
}
