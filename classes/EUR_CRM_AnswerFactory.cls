public with sharing class EUR_CRM_AnswerFactory {

	public interface IQuestionsInterface{
	    void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions);
	    
	    Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                        List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                        String target, String initValue);
	                                                        
	   Component.Apex.PageBlockSection getQuestionComponent(Id accountId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                        List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                        String target, String initValue);
	    
	    Double calculateQuestion(Double thresholdWeight, 
	                            List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                            String answer);
	    
	    List<String> getFieldSet();
	    
	    List<String> getLabelSet();
	    
	    boolean isRequired();
	}
	
	public virtual class QuestionFactoryBase
	{
	    public final String REQUIRED_STYLECLASS = 'requiredStyle';
	    public final String REQUIRED_BOOLEAN_STYLECLASS = 'requiredBooleanStyle';
	    
	}
	
	public class BooleanQuestions extends QuestionFactoryBase implements IQuestionsInterface{
	    public Component.Apex.OutputText questionStatement{set; get;}
	    public Component.Apex.SelectRadio possibleAnswer{set; get;}
	    
	    public boolean isRequired(){
	        return true;
	    }
	    
	    public void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions){
	        questionStatement = new Component.Apex.OutputText();
	        questionStatement.value = questionInfo.EUR_CRM_Question_Statement__c;
	        possibleAnswer = new Component.Apex.SelectRadio();

	        for (EUR_CRM_PRS_Question_Criteria__c option: possibleAnswerOptions){
	            Component.Apex.selectOption radioOption = new Component.Apex.selectOption();
	            radioOption.itemLabel = option.EUR_CRM_Criteria_Picklist_Label__c;
	            radioOption.itemValue = option.EUR_CRM_Criteria_Picklist_Value__c;
	            radioOption.itemDisabled = false;
	            possibleAnswer.childComponents.add(radioOption);
	        }
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
        {
            this.setQuestion(questionInfo, possibleAnswerOptions);
            if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
                possibleAnswer.value = initValue;
            }
            possibleAnswer.expressions.value = target;
            possibleAnswer.styleClass = this.REQUIRED_BOOLEAN_STYLECLASS;
            
            Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
            
            itemGroup.childComponents.add(questionStatement);
            itemGroup.childComponents.add(possibleAnswer);
            
            return itemGroup;
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(Id accoungtId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	           possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        
	        Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
	        panel1.styleClass = 'requiredInput';
	        panel1.layout= 'block';
	        Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
	        panel2.styleClass = 'requiredBlock';
	        panel2.layout = 'block';
	        
	        panel1.childComponents.add(panel2);
	        panel1.childComponents.add(possibleAnswer);
	        
	        
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(panel1);
	        
	        return itemGroup;
	    }
	    
	    public Double calculateQuestion(Double thresholdWeight, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, String answer)
	    {
	        System.debug('calculate1');
	        Double answerWeight = 0;
	        System.debug('Flag - Answer1:'+ answer);
	        System.debug('^^^possibleAnswerOptions' + possibleAnswerOptions);
	        for (EUR_CRM_PRS_Question_Criteria__c answerOption: possibleAnswerOptions){
	            answerOption.EUR_CRM_Criteria_Picklist_Value__c = (answerOption.EUR_CRM_Criteria_Picklist_Value__c!=null)?answerOption.EUR_CRM_Criteria_Picklist_Value__c:'';
	            if (answerOption.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(answer)){
	                answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
	            }
	        }
	        System.debug('^^^answerWeight' + answerWeight);
	        return answerWeight/100;
	    }
	    
	    public final String LABEL = 'label';
	    public final String FIELD = 'field';
	    
        public List<String> getFieldSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('EUR_CRM_Criteria_Picklist_Value__c');
	        fieldSet.add('EUR_CRM_Criteria_Picklist_Label__c');
	        
	        return fieldSet;
	    }
	   
	    public List<String> getLabelSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('Answer Value');
	        fieldSet.add('Answer Label');
	        fieldSet.add('Weight');
	        
	        return fieldSet;
	    } 
	}
	
	public class IntegerInputQuestions extends QuestionFactoryBase implements IQuestionsInterface{
	    public Component.Apex.OutputText questionStatement{set; get;}
	    public Component.Apex.InputText  possibleAnswer{set; get;}
	    
	    public boolean isRequired(){
	        return true;
	    }
	    
	    public void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions){
	        questionStatement = new Component.Apex.OutputText();
	        questionStatement.value = questionInfo.EUR_CRM_Question_Statement__c;
	        possibleAnswer = new Component.Apex.InputText();
	    }
	        
	    public Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	           possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        possibleAnswer.styleClass = this.REQUIRED_STYLECLASS;
	        possibleAnswer.onblur='return extractNumber(this,0,false)'; 
	        possibleAnswer.onkeyup='return extractNumber(this,0,false)'; 
	        possibleAnswer.onkeypress='return return blockNonNumbers(this, event, false, false)'; 
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(possibleAnswer);
	        
	        return itemGroup;
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(Id accountId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        possibleAnswer.expressions.value = target;
	        possibleAnswer.onblur='return extractNumber(this,0,false)'; 
	        possibleAnswer.onkeyup='return extractNumber(this,0,false)'; 
	        possibleAnswer.onkeypress='return return blockNonNumbers(this, event, false, false)';
	        
	        if(questionInfo.EUR_CRM_Question_Statement__c.equalsIgnoreCase(EUR_CRM_ProsSegmentationClass.IMAGE_LEVEL_STATEMENT)){
	           possibleAnswer.value = String.valueOf(EUR_CRM_ProsSegmentationClass.returnSuperPremium(accountId));
	           possibleAnswer.disabled = true;
	        }
	        else if ((initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)) && (!questionInfo.EUR_CRM_Question_Statement__c.equalsIgnoreCase(EUR_CRM_ProsSegmentationClass.IMAGE_LEVEL_STATEMENT))){
	           possibleAnswer.value = initValue;
	        }
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        
	        Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
	        panel1.styleClass = 'requiredInput';
	        panel1.layout= 'block';
	        Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
	        panel2.styleClass = 'requiredBlock';
	        panel2.layout = 'block';
	        
	        panel1.childComponents.add(panel2);
	        panel1.childComponents.add(possibleAnswer);
	        
	        
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(panel1);
	        
	        return itemGroup;
	    }	    
	    public Double calculateQuestion(Double thresholdWeight, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, String ans)
	    {
	        System.debug('calculate2');
	        System.debug('@@@ANS' + ans);
	        System.debug('Flag - Calculate Question Args:' + thresholdWeight + '-'+possibleAnswerOptions+'-'+ans);
	        Double answerWeight = 0;
	        Integer iVar;

	        for (EUR_CRM_PRS_Question_Criteria__c answerOption: possibleAnswerOptions)
	        {   
	            String condition = answerOption.EUR_CRM_Answer_Condition__c;
	            condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
	            System.debug('Flag-Condition: ' + condition + '|' + ans);
	            Boolean bool = false;
	            if(ans==null || ans== ''){
	                ans = '0';
                }
	                
	            Integer answer = Integer.valueOf(ans);
	            
	            if(answerOption.EUR_CRM_Criteria_Threshold_Number__c!=null){
	                Integer currentVar = Integer.valueOf(answer - answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                currentVar = (currentVar<0)?(currentVar*-1):currentVar;
	                System.debug('FLAG - Check Var:' + currentVar + '-' +iVar);
	                
	                if (condition.equalsIgnorecase('='))
	                {
	                    system.debug('con1' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = (answer == answerOption.EUR_CRM_Criteria_Threshold_Number__c) ? true: false;
	                    if(bool){
	                        iVar = currentVar;
                            if (answerOption.EUR_CRM_Criteria_Weight__c != null) {
                                System.debug('Flag - Ans Weight:' + answerOption.EUR_CRM_Criteria_Weight__c + '-' + answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight);
                                answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
                                break;
                            }
	                    } 
	                }
	                else if (condition.equalsIgnorecase('!='))
	                {
	                    system.debug('con2' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = (answer != answerOption.EUR_CRM_Criteria_Threshold_Number__c) ? true: false;
	                    if(bool){
	                        iVar = currentVar;
                            if (answerOption.EUR_CRM_Criteria_Weight__c != null) {
                                System.debug('Flag - Ans Weight:' + answerOption.EUR_CRM_Criteria_Weight__c + '-' + answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight);
                                answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
                                break;
                            }
	                    } 
	                }
	                else if (condition.equalsIgnorecase('<'))
	                {
	                    system.debug('con3' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = ((answer < answerOption.EUR_CRM_Criteria_Threshold_Number__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('>'))
	                {
	                    system.debug('con4' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = ((answer > answerOption.EUR_CRM_Criteria_Threshold_Number__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('<='))
	                {
	                    system.debug('con5' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = ((answer <= answerOption.EUR_CRM_Criteria_Threshold_Number__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('>='))
	                {
	                    system.debug('con6' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Number__c);
	                    bool = ((answer >= answerOption.EUR_CRM_Criteria_Threshold_Number__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
	                }
	                
	                if(bool){
	                    iVar = currentVar;
                        if (answerOption.EUR_CRM_Criteria_Weight__c != null) {
                            System.debug('Flag - Ans Weight:' + answerOption.EUR_CRM_Criteria_Weight__c + '-' + answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight);
                            answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
                        }
	                }
	            }
	        }
	        return answerWeight/100;
	    }
	    
	    public final String LABEL = 'label';
	    public final String FIELD = 'field';
	    
        public List<String> getFieldSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('EUR_CRM_Answer_Condition__c');
	        fieldSet.add('EUR_CRM_Criteria_Threshold_Number__c');
	        
	        return fieldSet;
	    }
	   
	    public List<String> getLabelSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('Answer Value');
	        fieldSet.add('Answer Label');
	        fieldSet.add('Weight');
	        
	        return fieldSet;
	    }
	}
	
	public class CurrencyInputQuestions extends QuestionFactoryBase implements IQuestionsInterface{
	    public Component.Apex.OutputText questionStatement{set; get;}
	    public Component.Apex.InputText  possibleAnswer{set; get;}
	    
	    public boolean isRequired(){
	        return true;
	    }        
	    
	    public void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions)
	    {
	        questionStatement = new Component.Apex.OutputText();
	        questionStatement.value = questionInfo.EUR_CRM_Question_Statement__c;
	        possibleAnswer = new Component.Apex.InputText ();
	    }
	        
	    public Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	           possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        possibleAnswer.styleClass = this.REQUIRED_STYLECLASS;
	        possibleAnswer.onblur='return extractNumber(this,2,false)'; 
	        possibleAnswer.onkeyup='return extractNumber(this,2,false)'; 
	        possibleAnswer.onkeypress='return return blockNonNumbers(this, event, true, false)'; 
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(possibleAnswer);
	        
	        return itemGroup;
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(Id accountId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	        possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        possibleAnswer.styleClass = this.REQUIRED_STYLECLASS;
	        possibleAnswer.onblur='return extractNumber(this,2,false)';
	        possibleAnswer.onkeyup='return extractNumber(this,2,false)'; 
	        possibleAnswer.onkeypress='return return blockNonNumbers(this, event, true, false)';
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        
	        Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
	        panel1.styleClass = 'requiredInput';
	        panel1.layout= 'block';
	        Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
	        panel2.styleClass = 'requiredBlock';
	        panel2.layout = 'block';
	        
	        panel1.childComponents.add(panel2);
	        panel1.childComponents.add(possibleAnswer);
	        
	        
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(panel1);
	        
	        return itemGroup;
	    }

	    public Double calculateQuestion(Double thresholdWeight, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, String ans)
	    {
	        System.debug('calculate3');
	        Double answerWeight = 0;
	        Double iVar;

	        for (EUR_CRM_PRS_Question_Criteria__c answerOption: possibleAnswerOptions)
	        {   
	            String condition = answerOption.EUR_CRM_Answer_Condition__c;
	            condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
	            System.debug('Flag-Condition: ' + condition);
	            System.debug('Flag - Answer2:' + ans);
	            if(ans==null || ans==''){
	                ans = '0';
                }
	            
	            Double answer = Double.valueOf(ans);
	            if (answerOption.EUR_CRM_Criteria_Threshold_Currency__c != null){
	                Double currentVar = answer-answerOption.EUR_CRM_Criteria_Threshold_Currency__c;
	                currentVar = (currentVar<0)?(currentVar*-1):currentVar;
	                System.debug('FLAG - Check Var:' + currentVar + '-' +iVar);
	                
	                Boolean bool = false;
	                if (condition.equalsIgnorecase('='))
	                {
	                    system.debug('curr1' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = (answer == answerOption.EUR_CRM_Criteria_Threshold_Currency__c) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('!='))
	                {
	                    system.debug('curr2' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = (answer != answerOption.EUR_CRM_Criteria_Threshold_Currency__c) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('<'))
	                {
	                    system.debug('curr3' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = ((answer < answerOption.EUR_CRM_Criteria_Threshold_Currency__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('>'))
	                {
	                    system.debug('curr4' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = ((answer > answerOption.EUR_CRM_Criteria_Threshold_Currency__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('<='))
	                {
	                    system.debug('curr5' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = ((answer <= answerOption.EUR_CRM_Criteria_Threshold_Currency__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
	                }
	                else if (condition.equalsIgnorecase('>='))
	                {
	                    system.debug('curr6' + answer + ':' + answerOption.EUR_CRM_Criteria_Threshold_Currency__c);
	                    bool = ((answer >= answerOption.EUR_CRM_Criteria_Threshold_Currency__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
	                }
	                
	                if(bool){
	                    iVar = currentVar;
                        if (answerOption.EUR_CRM_Criteria_Weight__c != null) {
                            answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
                        }
	                }
	            }
	        }
	        return answerWeight/100;
	    }
	    
	    public final String LABEL = 'label';
	    public final String FIELD = 'field';
	    
        public List<String> getFieldSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('EUR_CRM_Answer_Condition__c');
	        fieldSet.add('EUR_CRM_Criteria_Threshold_Currency__c');
	        
	        return fieldSet;
	    }
	   
	    public List<String> getLabelSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('Answer Value');
	        fieldSet.add('Answer Label');
	        fieldSet.add('Weight');
	        
	        return fieldSet;
	        
	   }
	}
	
	public class PicklistQuestions extends QuestionFactoryBase implements IQuestionsInterface{
	    public Component.Apex.OutputText questionStatement{set; get;}
	    public Component.Apex.SelectList possibleAnswer{set; get;}

	    public boolean isRequired(){
	        return true;
	    }
	    
	    public void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions)
	    {
	        questionStatement = new Component.Apex.OutputText();
	        questionStatement.value = questionInfo.EUR_CRM_Question_Statement__c;
	        
	        possibleAnswer = new Component.Apex.SelectList();
	        possibleAnswer.size = 1;
	        possibleAnswer.multiSelect = false;
	        
            for (EUR_CRM_PRS_Question_Criteria__c option: possibleAnswerOptions) {
	            Component.Apex.selectOption listOption = new Component.Apex.selectOption();
	            listOption.itemLabel = option.EUR_CRM_Criteria_Picklist_Label__c;
	            listOption.itemValue = option.EUR_CRM_Criteria_Picklist_Value__c;
	            listOption.itemDisabled = false;
	            possibleAnswer.childComponents.add(listOption);
	        }
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        possibleAnswer.expressions.value = target;
	        possibleAnswer.styleClass = this.REQUIRED_STYLECLASS;
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(possibleAnswer);
	        
	        return itemGroup;
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(Id accountId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);

	        possibleAnswer.expressions.value = target;
	        possibleAnswer.styleClass = this.REQUIRED_STYLECLASS;
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

	        Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
	        panel1.styleClass = 'requiredInput';
	        panel1.layout= 'block';

	        Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
	        panel2.styleClass = 'requiredBlock';
	        panel2.layout = 'block';
	        
	        panel1.childComponents.add(panel2);
	        panel1.childComponents.add(possibleAnswer);
	        
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(panel1);
	        
	        return itemGroup;
	    }
	    
	    public Double calculateQuestion(Double thresholdWeight, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, String answer)
	    {
            System.debug('\n possibleAnswerOptions => ' + JSON.serializePretty(possibleAnswerOptions) + '\n');
	        Double answerWeight = 0;
	        for (EUR_CRM_PRS_Question_Criteria__c answerOption: possibleAnswerOptions){
	            answerOption.EUR_CRM_Criteria_Picklist_Value__c = (answerOption.EUR_CRM_Criteria_Picklist_Value__c!=null)?answerOption.EUR_CRM_Criteria_Picklist_Value__c:'';
	            if (answerOption.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(answer)){
                    if (answerOption.EUR_CRM_Criteria_Weight__c != null) {
                        answerWeight = answerOption.EUR_CRM_Criteria_Weight__c * thresholdWeight;
                    }
	            }
	        }
	        return answerWeight/100;
	    }
	    
	    public final String LABEL = 'label';
	    public final String FIELD = 'field';
	    public List<String> getFieldSet() {
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('EUR_CRM_Criteria_Picklist_Value__c');
	        
	        return fieldSet;
	    }
	   
	    public List<String> getLabelSet(){
	        List<String> fieldSet = new List<String>();
	        
	        fieldSet.add('Answer Value');
	        fieldSet.add('Answer Label');
	        fieldSet.add('Weight');
	        
	        return fieldSet;
	   }
	}
	
	public class TextInputQuestions extends QuestionFactoryBase implements IQuestionsInterface{
	    public Component.Apex.OutputText questionStatement{set; get;}
	    public Component.Apex.InputText possibleAnswer{set; get;}
	    
	    public boolean isRequired(){
	        return false;
	    }
	    
	    public void setQuestion(EUR_CRM_PRS_Question__c questionInfo, List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions)
	    {
	        questionStatement = new Component.Apex.OutputText();
	        questionStatement.value = questionInfo.EUR_CRM_Question_Statement__c;
	        possibleAnswer = new Component.Apex.InputText();
	    }
	        
	    public Component.Apex.PageBlockSection getQuestionComponent(EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	           possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(possibleAnswer);
	        
	        return itemGroup;
	    }
	    
	    public Component.Apex.PageBlockSection getQuestionComponent(Id accountId, EUR_CRM_PRS_Question__c questionInfo, 
	                                                                List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                                                String target, String initValue)
	    {
	        this.setQuestion(questionInfo, possibleAnswerOptions);
	        if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)){
	           possibleAnswer.value = initValue;
            }
	        possibleAnswer.expressions.value = target;
	        
	        Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
	        itemGroup.childComponents.add(questionStatement);
	        itemGroup.childComponents.add(possibleAnswer);
	        
	        return itemGroup;
	    }	    
	    public Double calculateQuestion(Double thresholdWeight, 
	                                   List<EUR_CRM_PRS_Question_Criteria__c> possibleAnswerOptions, 
	                                   String answer)
	    {
	        return 0;
	    }
	    
	    public List<String> getFieldSet()
	    {
	        return new List<String>();
	    }
	    
	    public List<String> getLabelSet()
	    {
	        return new List<String>();
	    }
	}
}