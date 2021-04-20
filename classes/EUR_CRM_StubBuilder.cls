public with sharing class EUR_CRM_StubBuilder {

	private final Type stubbedEntityType;
	private Map<String, List<EUR_CRM_Method>> methodsByName;

	public EUR_CRM_StubBuilder(Type stubbedEntityType) {
		this.stubbedEntityType = stubbedEntityType;
		this.methodsByName = new Map<String, List<EUR_CRM_Method>>();
	}

	//public methods
	public EUR_CRM_StubBuilder clearMethodMocks() {
		this.methodsByName = new Map<String, List<EUR_CRM_Method>>();
		return this;
	}

	public EUR_CRM_StubBuilder withStub(EUR_CRM_Method method) {
		if (!this.methodsByName.containsKey(method.getName())) {
			this.methodsByName.put(method.getName(), new List<EUR_CRM_Method>());
		}
		this.methodsByName.get(method.getName()).add(method);
		return this;
	}

	public EUR_CRM_StubBuilder preview() {
		System.debug(this.toString());
		return this;
	}

	public override String toString() {
		List<String> allMethods = new List<String>();
		for (List<EUR_CRM_Method> methods : this.methodsByName.values()) {
			for (EUR_CRM_Method method : methods) {
				allMethods.add('\t' + this.stubbedEntityType + method.toString());
			}
		}
		return '\nStub for ' + this.stubbedEntityType + ':\n' + String.join(allMethods, '\n') + '\n';
	}

	public Object getStubbedInstance() {
		return Test.createStub(this.stubbedEntityType, new MockProvider(this.stubbedEntityType, this.methodsByName));
	}


	//mock provider class
	public class MockProvider implements System.StubProvider {

		private final Type stubbedEntityType;
		private final Map<String, List<EUR_CRM_Method>> methodsByName;

		public MockProvider(Type stubbedEntityType, Map<String, List<EUR_CRM_Method>> methodsByName) {
			this.stubbedEntityType = stubbedEntityType;
			for (List<EUR_CRM_Method> methods : methodsByName.values()) {
				methods.sort();
			}
			this.methodsByName = methodsByName;
		}

		public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
			Type returnType, List<Type> listOfArgumentTypes, List<String> listOfParamNames,
			List<Object> listOfArgs) {
			List<EUR_CRM_Method> stubbedMethods = this.methodsByName.get(stubbedMethodName);
			if (stubbedMethods == null || stubbedMethods.isEmpty()) {
				System.debug('Method "' + stubbedMethodName + '" is not stubbed');
				return null;
			}

			List<EUR_CRM_Argument> arguments = this.convertToArguments(listOfArgumentTypes, listOfArgs);
			for (EUR_CRM_Method stubbedMethodCall : stubbedMethods) {
				if (stubbedMethodCall.matchMethodCallParams(arguments)) {
					stubbedMethodCall.handleException();
					return stubbedMethodCall.getReturnValue();
				}
			}
			System.debug('Method "' + stubbedMethodName + '" with arguments ' + arguments + ' is not stubbed');
			return null;
		}

		private List<EUR_CRM_Argument> convertToArguments(List<Type> listOfArgumentTypes, List<Object> listOfArgs) {
			final List<EUR_CRM_Argument> arguments = new List<EUR_CRM_Argument>();
			for (Integer i = 0; i < listOfArgumentTypes.size(); i++) {
				Type type = listOfArgumentTypes[i];
				Object value = listOfArgs[i];
				arguments.add(new EUR_CRM_Argument(type, value));
			}
			return arguments;
		}

		public override String toString() {
			List<String> allMethods = new List<String>();
			for (List<EUR_CRM_Method> methods : this.methodsByName.values()) {
				for (EUR_CRM_Method method : methods) {
					allMethods.add('\t' + this.stubbedEntityType + method.toString());
				}
			}
			return '\nStub for ' + this.stubbedEntityType + ':\n' + String.join(allMethods, '\n') + '\n';
		}
	}

	//method class
	public class EUR_CRM_Method implements Comparable {

		private final String name;
		private final List<EUR_CRM_Argument> arguments;
		private Object returnValue;
		private String exceptionMessage;
		private Type expectedExceptionType;

		public EUR_CRM_Method(String methodName) {
			this.name = methodName;
			this.arguments = new List<EUR_CRM_Argument>();
		}

		public String getName() {
			return this.name;
		}

		public List<EUR_CRM_Argument> getArguments() {
			return this.arguments;
		}

		public Object getReturnValue() {
			return this.returnValue;
		}

		public Type getExpectedExceptionType() {
			return this.expectedExceptionType;
		}

		public Boolean matchMethodCallParams(List<EUR_CRM_Argument> callArguments) {
			if (this.getArguments().size() != callArguments.size()) {
				return false;
			}
			for (Integer i = 0; i < this.getArguments().size(); i++) {
				EUR_CRM_Argument thisMethodArgument = this.arguments[i];
				EUR_CRM_Argument callArgument = callArguments[i];

				if (!thisMethodArgument.equals(callArgument)) {
					return false;
				}
			}
			return true;
		}

		public EUR_CRM_Method addArgument(Type argumentType) {
			return this.addArgument(new EUR_CRM_AnyValueArgument(argumentType));
		}

		public EUR_CRM_Method addArgument(Type argumentType, Object value) {
			return this.addArgument(new EUR_CRM_Argument(argumentType, value));
		}

		public EUR_CRM_Method addArgument(EUR_CRM_Argument argument) {
			this.arguments.add(argument);
			return this;
		}

		public EUR_CRM_Method addArguments(List<Type> argumentTypes) {
			for (Type argumentType : argumentTypes) {
				this.addArgument(new EUR_CRM_AnyValueArgument(argumentType));
			}
			return this;
		}

		public EUR_CRM_Method addArguments(List<EUR_CRM_Argument> arguments) {
			this.arguments.addAll(arguments);
			return this;
		}

		public EUR_CRM_Method addValue(Object value) {
			return this.addArgument(new EUR_CRM_AnyTypeArgument(value));
		}

		public EUR_CRM_Method addValues(List<Object> values) {
			for (Object value : values) {
				this.addValue(value);
			}
			return this;
		}

		public EUR_CRM_Method addAnyArgument() {
			return this.addArgument(new EUR_CRM_AnyArgument());
		}

		public EUR_CRM_Method addAnyArguments(Integer numberOfAnyArguments) {
			for (Integer i = 0; i < numberOfAnyArguments; i++) {
				this.addArgument(new EUR_CRM_AnyArgument());
			}
			return this;
		}

		public EUR_CRM_Method returnValue(Object returnValue) {
			this.returnValue = returnValue;
			return this;
		}

		public EUR_CRM_Method throwException(Type expectedExceptionType) {
			this.expectedExceptionType = expectedExceptionType;
			return this;
		}

		public EUR_CRM_Method throwException(Type expectedExceptionType, String exceptionMessage) {
			this.expectedExceptionType = expectedExceptionType;
			this.exceptionMessage = exceptionMessage;
			return this;
		}

		public EUR_CRM_Method preview() {
			System.debug(this.toString());
			return this;
		}

		public override String toString() {
			List<String> stringifiedArguments = new List<String>();
			for (EUR_CRM_Argument argument : this.arguments) {
				stringifiedArguments.add(argument.toString());
			}
			return '.' + this.getName() + '(' + String.join(stringifiedArguments, ', ') + ')'
				+ (
				this.getExpectedExceptionType() == null ?
					' returning: "' + this.getReturnValue() + '"' :
					' throwing: "' + this.getExpectedExceptionType() + '"'
			);
		}

		public Integer compareTo(Object obj) {
			EUR_CRM_Method otherMethod = (EUR_CRM_Method) obj;
			Integer thisMethodParamSize = this.getArguments().size();
			Integer otherMethodParamSize = otherMethod.getArguments().size();

			if (thisMethodParamSize > otherMethodParamSize) {
				return -1;
			} else if (thisMethodParamSize < otherMethodParamSize) {
				return 1;
			}
			Integer thisMethodPriority = this.getMethodPriority();
			Integer otherMethodPriority = otherMethod.getMethodPriority();
			if (thisMethodPriority > otherMethodPriority) {
				return -1;
			}
			if (thisMethodPriority < otherMethodPriority) {
				return 1;
			}
			return 0;
		}

		private Integer getMethodPriority() {
			Integer priority = 0;
			for (EUR_CRM_Argument argument : this.getArguments()) {
				priority += argument.getArgumentPriority();
			}
			return priority;
		}

		private void handleException() {
			if (this.expectedExceptionType == null) {
				return;
			}
			Exception expectedException = (Exception) this.expectedExceptionType.newInstance();
			if (String.isNotEmpty(this.exceptionMessage)) {
				expectedException.setMessage(this.exceptionMessage);
			}
			throw expectedException;
		}
	}


	//arguments class set
	public virtual class EUR_CRM_Argument {

		private final Type type;
		private final Object value;

		public EUR_CRM_Argument(Type type, Object value) {
			this.type = type;
			this.value = value;
		}

		public Type getType() {
			return type;
		}

		public Object getValue() {
			return value;
		}

		public virtual Integer getArgumentPriority() {
			return (this.getType() == EUR_CRM_AnyType.class ? 0 : 1) +
				(this.getValue() instanceof EUR_CRM_AnyValue ? 0 : 2);
		}

		public override String toString() {
			return this.type.toString() + ' = ' + this.value;
		}

		private virtual Boolean equals(EUR_CRM_Argument argument) {
			return this.getType() == argument.getType()
				&& this.getValue() == argument.getValue();
		}
	}

	public class EUR_CRM_AnyTypeArgument extends EUR_CRM_Argument {

		private EUR_CRM_AnyTypeArgument(Object value) {
			super(EUR_CRM_AnyType.class, value);
		}

		private override Boolean equals(EUR_CRM_Argument argument) {
			return this.getValue() == argument.getValue();
		}
	}

	public class EUR_CRM_AnyValueArgument extends EUR_CRM_Argument {

		private EUR_CRM_AnyValueArgument(Type type) {
			super(type, new EUR_CRM_AnyValue());
		}

		private override Boolean equals(EUR_CRM_Argument argument) {
			return this.getType() == argument.getType();
		}
	}

	public class EUR_CRM_AnyArgument extends EUR_CRM_Argument {

		private EUR_CRM_AnyArgument() {
			super(EUR_CRM_AnyType.class, new EUR_CRM_AnyValue());
		}

		public override Integer getArgumentPriority() {
			return -1;
		}

		private override Boolean equals(EUR_CRM_Argument argument) {
			return true;
		}
	}


	//any type or value stub classes
	private class EUR_CRM_AnyType {

		public override String toString() {
			return 'AnyType.class';
		}
	}

	private class EUR_CRM_AnyValue {

		public override String toString() {
			return '<Any Value>';
		}
	}
}