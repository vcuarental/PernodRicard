public class ASI_CRM_JP_DataTableService {

	private static final Integer DEFAULT_PAGE_SIZE = 1000;

	private ASI_CRM_JP_DataTableService instance;

	public ASI_CRM_JP_DataTableService getInstance() {

		if (instance == null) instance = new ASI_CRM_JP_DataTableService();

		return instance;
	}

	public static void updateRecords(List<SObject> records) {
		update records;
	}

	public static SObject cloneRecord(Id recordId) {

		String query = 'SELECT ';
		query += String.join(new List<String>(recordId.getSObjectType().getDescribe().fields.getMap().keySet()), ',');
		query += ' FROM ' + recordId.getSObjectType().getDescribe().getName() + ' WHERE Id = ' +
				ASI_CRM_QueryUtil.encloseWithQuotes(recordId);

		final SObject baseRecord = Database.query(query);
		final SObject newRecord = baseRecord.clone(true, true, false, false);
//		newRecord.recalculateFormulas();

		return newRecord;
	}

	public static PageRequest deserializePageRequest(String serializedJsonString) {

		if (String.isBlank(serializedJsonString)) return new PageRequest();

		return (PageRequest) JSON.deserialize(serializedJsonString, PageRequest.class);
	}

	public static PageRequest deserializePageRequest(String serializedJsonString,
													 String sObjectName,
													 String customCriteria) {

		if (String.isBlank(serializedJsonString)) return new PageRequest();

		final PageRequest pageRequest = deserializePageRequest(serializedJsonString);
		pageRequest.setsObjectName(sObjectName);
		pageRequest.setCustomCriteria(customCriteria);

		System.debug(pageRequest);

		return pageRequest;
	}

	public static String getQueryString(PageRequest pageRequest) {
		final String customCriteria = pageRequest.getCustomCriteria();
		final String criteria = createCriteriaString(pageRequest.getCriterion());

		final List<String> fields = pageRequest.getSelectFieldsList();
		String queryString = 'SELECT ' + getSelectFieldsQueryString(fields);
		queryString += ' FROM ' + pageRequest.getsObjectName() + ' ';
		queryString += createCriteriaString(criteria, customCriteria) + ' ';
		queryString += createSortCriteriaString(pageRequest) + ' ';
		queryString += createLimitCriteriaString(null);

		return queryString;
	}

    @TestVisible
	private static String getSelectFieldsQueryString(List<String> fields) {

		if (fields == null) return ' Id ';

		return String.join(fields, ' ,');
	}

	public static String createCriteriaString(List<Criteria> criterion) {

		if (criterion == null || criterion.isEmpty()) return '';

		final List<String> criteriaStrings = new List<String>();
		for (Criteria criteria : criterion) {
			final List<String> keywords = criteria.getKeywords();

			if (String.isBlank(keywords.get(0))) continue;

			final String fieldName = criteria.getFieldName();
			String criteriaString = '';
			if (criteria.getOperator().equals(Operator.CONTAINS)) {

				criteriaString += fieldName + ' LIKE ' + ASI_CRM_QueryUtil.encloseWithQuotes('%' + clean(keywords.get(0)) + '%');
			} else if (criteria.getOperator().equals(Operator.EQUALS) && String.isNotBlank(keywords.get(0))) {

				criteriaString += fieldName + ' = ' + clean(keywords.get(0));
			} else if (criteria.getOperator().equals(Operator.BETWEEN)) {
				String betweenCriteria = '';
				if (String.isNotBlank(keywords.get(0))) {
					betweenCriteria += fieldName + ' >= ' + clean(keywords.get(0));
				}
				if (String.isNotBlank(keywords.get(0)) && String.isNotBlank(keywords.get(1))) {
					betweenCriteria += ' AND ';
				}
				if (String.isNotBlank(keywords.get(1))) {
					betweenCriteria += fieldName + ' <= ' + clean(keywords.get(1));
				}
				criteriaString += '(' + betweenCriteria + ')';
			} else if (criteria.getOperator().equals(Operator.LESS_THAN) && String.isNotBlank(keywords.get(0))) {

				criteriaString += fieldName + ' < ' + clean(keywords.get(0));
			} else if (criteria.getOperator().equals(Operator.GREATER_THAN) && String.isNotBlank(keywords.get(0))) {

				criteriaString += fieldName + ' > ' + clean(keywords.get(0));
			}
			criteriaStrings.add(criteriaString);
		}

		return String.join(criteriaStrings, ' AND ');
	}
	@TestVisible
	private static String createCriteriaString(String criteria, String customCriteria) {

		String criteriaString = '';

		if (!String.isBlank(criteria)) criteriaString = ' WHERE ' + criteria;

		if (String.isBlank(customCriteria)) return criteriaString;

		if (String.isBlank(criteriaString)) {
			return ' WHERE ' + customCriteria;
		} else {
			return criteriaString + ' AND ' + customCriteria;
		}
	}
	@TestVisible
	private static String createLimitCriteriaString(Integer pageSize) {

		String limitQueryString = ' LIMIT ';

		if (pageSize == null || pageSize < 1) return limitQueryString + DEFAULT_PAGE_SIZE;

		return limitQueryString + pageSize;
	}
    @TestVisible
	private static String createSortCriteriaString(PageRequest pageRequest) {
		final String sortField = pageRequest.getSortField();
		final String sortOrder = pageRequest.getSortOrder();
		final String defaultSortField = pageRequest.getDefaultSortField();
		final String defaultSortOrder = pageRequest.getDefaultSortOrder();

		if (String.isNotBlank(sortField) || String.isNotBlank(sortOrder)) {
			return ' ORDER BY ' + sortField + ' ' + sortOrder;
		}

		if (String.isNotBlank(defaultSortField) || String.isNotBlank(defaultSortOrder)) {
			return ' ORDER BY ' + defaultSortField + ' ' + defaultSortOrder;
		}

		return '';
	}

	public static String getListForQuery(List<String> values) {
		return '(\'' + String.join(values, '\' , \'') + '\')';
	}
	@TestVisible
	private static String clean(String value) {
		if (value == null) return value;

		return value.trim();
	}

	public class PageRequest {
		@TestVisible private String sObjectName;
		@TestVisible private String selectFields;
		private String customCriteria;
		private List<Criteria> criterion;
		private Integer pageSize;
		private Integer pageNumber;
		private String sortField;
		private String sortOrder;
		private String defaultSortField;
		private String defaultSortOrder;

		public List<String> getSelectFieldsList() {
			if (this.selectFields == null) return new List<String>();

			return this.selectFields.split(',');
		}

		public void combine(PageRequest pr) {
			if (this == null) return;

			if (String.isBlank(sObjectName)) this.sObjectName = pr.sObjectName;
			if (String.isBlank(selectFields)) this.selectFields = pr.selectFields;
			if (String.isBlank(customCriteria)) this.customCriteria = pr.customCriteria;
			if (this.criterion == null) this.criterion = pr.criterion;
			if (this.pageSize == null) this.pageSize = pr.pageSize;
			if (this.pageNumber == null) this.pageNumber = pr.pageNumber;
			if (String.isBlank(sortField)) this.sortField = pr.sortField;
			if (String.isBlank(sortOrder)) this.sortOrder = pr.sortOrder;
			if (String.isBlank(defaultSortField)) this.defaultSortField = pr.defaultSortField;
			if (String.isBlank(defaultSortOrder)) this.defaultSortOrder = pr.defaultSortOrder;
		}

		public String getCustomCriteria() {
			return customCriteria;
		}

		public List<Criteria> getCriterion() {
			return criterion;
		}

		public String getsObjectName() {
			return sObjectName;
		}

		public Integer getPageSize() {
			return pageSize;
		}

		public Integer getPageNumber() {
			return pageNumber;
		}

		public void setsObjectName(String sObjectName) {
			this.sObjectName = sObjectName;
		}

		public void setCustomCriteria(String customCriteria) {
			this.customCriteria = customCriteria;
		}

		public String getSortField() {
			return sortField;
		}

		public void setSortField(String sortField) {
			this.sortField = sortField;
		}

		public String getSortOrder() {
			return sortOrder;
		}

		public void setSortOrder(String sortOrder) {
			this.sortOrder = sortOrder;
		}

		public String getDefaultSortField() {
			return defaultSortField;
		}

		public void setDefaultSortField(String defaultSortField) {
			this.defaultSortField = defaultSortField;
		}

		public String getDefaultSortOrder() {
			return defaultSortOrder;
		}

		public void setDefaultSortOrder(String defaultSortOrder) {
			this.defaultSortOrder = defaultSortOrder;
		}

		public String getSelectFields() {
			return selectFields;
		}

		public void setSelectFields(String selectFields) {
			this.selectFields = selectFields;
		}
	}

	public class Criteria {
		private String fieldName;
		private String type;
		private List<String> keywords;
		private Operator operator;

		public String getFieldName() {
			return fieldName;
		}

        public void setFieldName(String fieldName) {
			this.fieldName = fieldName;
        }
        
		public String getType() {
			return type;
		}

        public void setType(String type) {
			this.type = type;
        }
        
		public List<String> getKeywords() {
			return keywords;
		}

        public void setKeywords(List<String> keywords) {
			this.keywords = keywords;
        }
        
		public Operator getOperator() {
			return operator;
		}
        
        public void setOperator(Operator operator) {
            this.operator = operator;
        }
	}

	public enum Operator {
			EQUALS, BETWEEN, GREATER_THAN, LESS_THAN, CONTAINS
	}

	public enum InputType {
			TEXT, PICKLIST, CHECKBOX
	}

}