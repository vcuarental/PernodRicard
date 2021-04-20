@IsTest(IsParallel = true)
private class EUR_CRM_StubBuilderTest {

	@IsTest
	private static void addAnyArgument_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get')
					.addAnyArgument()
					.returnValue('any argument')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get(0);

		//Then
		System.assertEquals('any argument', actualValue);
	}

	@IsTest
	private static void addArgumentWithTypeAndValueConstructor_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get2')
					.addArgument(Integer.class, 0)
					.addArgument(String.class, 'any')
					.returnValue('return value')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get2(0, 'any');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void addArgumentWithTypeConstructor_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get2')
					.addArgument(Integer.class)
					.addArgument(String.class)
					.returnValue('return value')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get2(5, 'any value');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void addArgumentsWithListOfArgumentsConstructor_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get2')
					.addArguments(new List<EUR_CRM_StubBuilder.EUR_CRM_Argument>{
						new EUR_CRM_StubBuilder.EUR_CRM_Argument(Integer.class, 0),
						new EUR_CRM_StubBuilder.EUR_CRM_Argument(String.class, 'any value') })
					.returnValue('return value')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get2(0, 'any value');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void addArgumentsWithListOfTypesConstructor_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get2')
					.addArguments(new List<Type>{ Integer.class, String.class })
					.returnValue('return value')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get2(0, 'any value');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void addValues_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get3')
					.addValues(new List<Object>{ 1, 'any value' })
					.returnValue('return value')
			).getStubbedInstance();

		//When
		String actualValue = stubList.get3(1, 'any value');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void methodCompareTo_Test() {
		//Given
		EUR_CRM_StubBuilder.EUR_CRM_Method methodOne = new EUR_CRM_StubBuilder.EUR_CRM_Method('get3')
			.addArguments(new List<Type>{Integer.class, String.class})
			.returnValue('get3 value');

		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(methodOne)
			.clearMethodMocks()
			.getStubbedInstance();

		//When
		String actualValue = stubList.get3(0,'any');

		//Then
		System.assertEquals(null, actualValue);
	}

	@IsTest
	private static void clearMethodMocks_Test() {
		//Given
		EUR_CRM_StubBuilder.EUR_CRM_Method methodOne = new EUR_CRM_StubBuilder.EUR_CRM_Method('get3')
			.addArguments(new List<Type>{Integer.class, String.class})
			.returnValue('get3 value');
		EUR_CRM_StubBuilder.EUR_CRM_Method methodTwo = new EUR_CRM_StubBuilder.EUR_CRM_Method('get2')
			.addAnyArguments(2)
			.returnValue('get2 value');

		//When
		Integer compare = methodOne.compareTo(methodTwo);

		//Then
		System.assertEquals(-1, compare);
	}

	@IsTest
	private static void preview_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('get3')
					.addAnyArguments(2)
					.returnValue('return value')
					.preview()
			)
			.preview()
			.getStubbedInstance();

		//When
		String actualValue = stubList.get3(1, 'any value');

		//Then
		System.assertEquals('return value', actualValue);
	}

	@IsTest
	private static void throwException_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('isEmpty')
					.throwException(MyException.class)
					.returnValue('return value')
			).getStubbedInstance();

		try {
			//When
			Boolean actualValue = stubList.isEmpty();
		} catch(MyException e) {
			//Then
			System.assertEquals('EUR_CRM_StubBuilderTest.MyException', e.getTypeName());
		}
	}

	@IsTest
	private static void throwExceptionWithExpectedMessage_Test() {
		//Given
		EUR_CRM_StubListTest stubList = (EUR_CRM_StubListTest) new EUR_CRM_StubBuilder(EUR_CRM_StubListTest.class)
			.withStub(
				new EUR_CRM_StubBuilder.EUR_CRM_Method('isEmpty')
					.throwException(MyException.class, 'Expected message')
					.returnValue('return value')
			).getStubbedInstance();

		try {
			//When
			Boolean actualValue = stubList.isEmpty();
		} catch(MyException e) {
			//Then
			System.assertEquals('Expected message', e.getMessage());
		}
	}

	private class MyException extends Exception {}
}