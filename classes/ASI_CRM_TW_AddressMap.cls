public class ASI_CRM_TW_AddressMap {

	public class Address_components {
		public String long_name;
		public String short_name;
		public List<String> types;
	}

	public class Geometry {
		public Bounds bounds;
		public Northeast location;
		public String location_type;
		public Bounds viewport;
	}

	public class Results {
		public List<Address_components> address_components;
		public String formatted_address;
		public Geometry geometry;
		public String place_id;
		public List<String> types;
	}

	public class Bounds {
		public Northeast northeast;
		public Northeast southwest;
	}

	public List<Results> results;
	public String status;

	public class Northeast {
		public Double lat;
		public Double lng;
	}

	
	public static ASI_CRM_TW_AddressMap parse(String json) {
		return (ASI_CRM_TW_AddressMap) System.JSON.deserialize(json, ASI_CRM_TW_AddressMap.class);
	}
}