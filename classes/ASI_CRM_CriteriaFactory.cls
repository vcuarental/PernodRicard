public with sharing class ASI_CRM_CriteriaFactory {

    public interface ICriteriaInterface{
        void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions);
        
        Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                            List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                            String target, String initValue);
                                                            
       Component.Apex.PageBlockSection getCriteriaComponent(Id accountId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                            List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                            String target, String initValue);
        
        Double calculateCriteria(Double thresholdWeight, 
                                List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                String answer);
        
        List<String> getFieldSet();
        
        List<String> getLabelSet();
        
        boolean isRequired();
    }
    
    public virtual class CriteriaFactoryBase
    {
        public final String REQUIRED_STYLECLASS = 'requiredStyle';
        public final String REQUIRED_BOOLEAN_STYLECLASS = 'requiredBooleanStyle';
        
    }
    
    public class BooleanCriteria extends CriteriaFactoryBase implements ICriteriaInterface{
        public Component.Apex.OutputText criteriaStatement{set; get;}
        public Component.Apex.SelectRadio criteriaAnswer{set; get;}
        
        public boolean isRequired(){
            return true;
        }
        
        public void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions){
            criteriaStatement = new Component.Apex.OutputText();
            criteriaStatement.value = criteriaInfo.ASI_CRM_SG_Question__c;
            
            criteriaAnswer = new Component.Apex.SelectRadio();
            //List <SelectOption> radioGroup = new List<SelectOption>();
            //Component.Apex.selectRadio radioGroup = new Component.Apex.selectRadio();
            for (ASI_CRM_Criteria_Answer__c option: criteriaAnswerOptions){
                //radioOPtions.add(new SelectOption(option.ASI_CRM_SG_Label__c, option.ASI_CRM_SG_Answer__r.ASI_CRM_SG_Value__c));
                 Component.Apex.selectOption radioOption = new Component.Apex.selectOption();
                 radioOption.itemLabel = option.ASI_CRM_SG_Label__c;
                 radioOption.itemValue = option.ASI_CRM_SG_Value__c;
                 radioOption.itemDisabled = false;
                 criteriaAnswer.childComponents.add(radioOption);
            }
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_BOOLEAN_STYLECLASS;
                //criteriaAnswer.label = ' ';
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
                //itemGroup.styleClass='requiredBlock';
                
                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(Id accoungtId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                //criteriaAnswer.styleClass = this.REQUIRED_BOOLEAN_STYLECLASS;
                //criteriaAnswer.label = ' ';
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();
                //itemGroup.styleClass='requiredBlock';
                
                Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
                panel1.styleClass = 'requiredInput';
                panel1.layout= 'block';

                Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
                panel2.styleClass = 'requiredBlock';
                panel2.layout = 'block';
                
                panel1.childComponents.add(panel2);
                panel1.childComponents.add(criteriaAnswer);
                
                
                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(panel1);
                
                return itemGroup;
        }
        
        public Double calculateCriteria(Double thresholdWeight, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, String answer)
        {
            System.debug('calculate1');
            Double answerWeight = 0;
            System.debug('Flag - Answer1:'+ answer);
            System.debug('^^^criteriaAnswerOptions' + criteriaAnswerOptions);
            for (ASI_CRM_Criteria_Answer__c answerOption: criteriaAnswerOptions){
                answerOption.ASI_CRM_SG_Value__c = (answerOption.ASI_CRM_SG_Value__c!=null)?answerOption.ASI_CRM_SG_Value__c:'';
                if (answerOption.ASI_CRM_SG_Value__c.equalsIgnorecase(answer)){
                    answerWeight = answerOption.ASI_CRM_SG_Weight__c * thresholdWeight;
                }
            }
            System.debug('^^^answerWeight' + answerWeight);
            return answerWeight/100;
        }
        
        public final String LABEL = 'label';
        public final String FIELD = 'field';
        public List<String> getFieldSet(){
            List<String> fieldSet = new List<String>();
            
            fieldSet.add('ASI_CRM_SG_Value__c');
            fieldSet.add('ASI_CRM_SG_Label__c');
            
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
    
    public class IntegerInputCriteria extends CriteriaFactoryBase implements ICriteriaInterface{
        public Component.Apex.OutputText criteriaStatement{set; get;}
        public Component.Apex.InputText  criteriaAnswer{set; get;}
        
        public boolean isRequired(){
            return true;
        }
        
        public void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions){
            criteriaStatement = new Component.Apex.OutputText();
            criteriaStatement.value = criteriaInfo.ASI_CRM_SG_Question__c;
            
            criteriaAnswer = new Component.Apex.InputText();
            //criteriaAnswer.
        }
            
        public Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.onKeyDown = 'return numbersOnly(event,this.value,this.id);';
                criteriaAnswer.onblur='return extractNumber(this,0,false)'; 
                criteriaAnswer.onkeyup='return extractNumber(this,0,false)'; 
                criteriaAnswer.onkeypress='return return blockNonNumbers(this, event, false, false)'; 
                                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(Id accountId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                //Component.Apex.OutputText criteriaAnswer = new Component.Apex.OutputText();
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                //criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.onKeyDown = 'return numbersOnly(event,this.value,this.id);';
                criteriaAnswer.onblur='return extractNumber(this,0,false)'; 
                criteriaAnswer.onkeyup='return extractNumber(this,0,false)'; 
                criteriaAnswer.onkeypress='return return blockNonNumbers(this, event, false, false)';
                
                if(criteriaInfo.ASI_CRM_SG_Question__c.equalsIgnoreCase(ASI_CRM_ProsSegmentationClass.IMAGE_LEVEL_STATEMENT)){
                    criteriaAnswer.value = String.valueOf(ASI_CRM_ProsSegmentationClass.returnSuperPremium(accountId));
                    criteriaAnswer.disabled = true;
                }
                else if ((initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0)) && (!criteriaInfo.ASI_CRM_SG_Question__c.equalsIgnoreCase(ASI_CRM_ProsSegmentationClass.IMAGE_LEVEL_STATEMENT))){
                    criteriaAnswer.value = initValue;
                }
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                //itemGroup.childComponents.add(criteriaStatement);
                //itemGroup.childComponents.add(criteriaAnswer);
                
                Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
                panel1.styleClass = 'requiredInput';
                panel1.layout= 'block';

                Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
                panel2.styleClass = 'requiredBlock';
                panel2.layout = 'block';
                
                panel1.childComponents.add(panel2);
                panel1.childComponents.add(criteriaAnswer);
                
                
                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(panel1);
                
                return itemGroup;
        }
        
        public Double calculateCriteria(Double thresholdWeight, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, String ans)
        {
            System.debug('calculate2');
            System.debug('@@@ANS' + ans);
            System.debug('Flag - Calculate Criteria Args:' + thresholdWeight + '-'+criteriaAnswerOptions+'-'+ans);
            Double answerWeight = 0;
            Integer iVar;
            /*
                Equal (=)
                Not Equal (!=)
                Less Than (<)
                Greater Than (>)
                Less Than or Equal (<=)
                Greater Than or Equal (>=)
            */
            for (ASI_CRM_Criteria_Answer__c answerOption: criteriaAnswerOptions)
            {   
                String condition = answerOption.ASI_CRM_SG_Condition__c;
                condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                System.debug('Flag-Condition: ' + condition + '|' + ans);
                Boolean bool = false;
                if(ans==null || ans== '')
                    ans = '0';
                    
                Integer answer = Integer.valueOf(ans);
                
                if(answerOption.ASI_CRM_SG_Base_Integer__c!=null){
                    Integer currentVar = Integer.valueOf(answer - answerOption.ASI_CRM_SG_Base_Integer__c);
                    currentVar = (currentVar<0)?(currentVar*-1):currentVar;
                    System.debug('FLAG - Check Var:' + currentVar + '-' +iVar);
                    
                    if (condition.equalsIgnorecase('='))
                    {
                        system.debug('con1' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = (answer == answerOption.ASI_CRM_SG_Base_Integer__c) ? true: false;
                        break;
                    }
                    else if (condition.equalsIgnorecase('!='))
                    {
                        system.debug('con2' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = (answer != answerOption.ASI_CRM_SG_Base_Integer__c) ? true: false;
                        break;
                    }
                    else if (condition.equalsIgnorecase('<'))
                    {
                        system.debug('con3' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = ((answer < answerOption.ASI_CRM_SG_Base_Integer__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('>'))
                    {
                        system.debug('con4' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = ((answer > answerOption.ASI_CRM_SG_Base_Integer__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('<='))
                    {
                        system.debug('con5' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = ((answer <= answerOption.ASI_CRM_SG_Base_Integer__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('>='))
                    {
                        system.debug('con6' + answer + ':' + answerOption.ASI_CRM_SG_Base_Integer__c);
                        bool = ((answer >= answerOption.ASI_CRM_SG_Base_Integer__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
                    }
                    
                    
                    if(bool){
                        iVar = currentVar;
                        
                        System.debug('Flag - Ans Weight:' + answerOption.ASI_CRM_SG_Weight__c + '-' + answerOption.ASI_CRM_SG_Weight__c * thresholdWeight);
                        answerWeight = answerOption.ASI_CRM_SG_Weight__c * thresholdWeight;
                    }
                }
            }
            return answerWeight/100;
        }
        
        public final String LABEL = 'label';
        public final String FIELD = 'field';
               public List<String> getFieldSet(){
            List<String> fieldSet = new List<String>();
            
            fieldSet.add('ASI_CRM_SG_Condition__c');
            fieldSet.add('ASI_CRM_SG_Base_Integer__c');
            
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
    
    public class CurrencyInputCriteria extends CriteriaFactoryBase implements ICriteriaInterface{
        public Component.Apex.OutputText criteriaStatement{set; get;}
        public Component.Apex.InputText  criteriaAnswer{set; get;}
        
        public boolean isRequired(){
            return true;
        }        
        
        public void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions)
        {
            criteriaStatement = new Component.Apex.OutputText();
            criteriaStatement.value = criteriaInfo.ASI_CRM_SG_Question__c;
            
            criteriaAnswer = new Component.Apex.InputText ();
        }
            
        public Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.onKeyDown = 'return numbersOnly(event,this.value,this.id);';
                criteriaAnswer.onblur='return extractNumber(this,2,false)'; 
                criteriaAnswer.onkeyup='return extractNumber(this,2,false)'; 
                criteriaAnswer.onkeypress='return return blockNonNumbers(this, event, true, false)'; 
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
         public Component.Apex.PageBlockSection getCriteriaComponent(Id accountId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.onKeyDown = 'return numbersOnly(event,this.value,this.id);';
                criteriaAnswer.onblur='return extractNumber(this,2,false)';
                criteriaAnswer.onkeyup='return extractNumber(this,2,false)'; 
                criteriaAnswer.onkeypress='return return blockNonNumbers(this, event, true, false)';
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                //itemGroup.childComponents.add(criteriaStatement);
                //itemGroup.childComponents.add(criteriaAnswer);
                
                Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
                panel1.styleClass = 'requiredInput';
                panel1.layout= 'block';

                Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
                panel2.styleClass = 'requiredBlock';
                panel2.layout = 'block';
                
                panel1.childComponents.add(panel2);
                panel1.childComponents.add(criteriaAnswer);
                
                
                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(panel1);
                
                return itemGroup;
        }
        
        public Double calculateCriteria(Double thresholdWeight, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, String ans)
        {
            System.debug('calculate3');
            Double answerWeight = 0;
            Double iVar;
            /*
                Equal (=)
                Not Equal (!=)
                Less Than (<)
                Greater Than (>)
                Less Than or Equal (<=)
                Greater Than or Equal (>=)
            */
            for (ASI_CRM_Criteria_Answer__c answerOption: criteriaAnswerOptions)
            {   
                String condition = answerOption.ASI_CRM_SG_Condition__c;
                condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                System.debug('Flag-Condition: ' + condition);
                System.debug('Flag - Answer2:' + ans);
                if(ans==null || ans=='')
                    ans = '0';
                
                Double answer = Double.valueOf(ans);
                if (answerOption.ASI_CRM_SG_Base_Currency__c != null){
                    Double currentVar = answer-answerOption.ASI_CRM_SG_Base_Currency__c;
                    currentVar = (currentVar<0)?(currentVar*-1):currentVar;
                    System.debug('FLAG - Check Var:' + currentVar + '-' +iVar);
                    
                    Boolean bool = false;
                    if (condition.equalsIgnorecase('='))
                    {
                        system.debug('curr1' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = (answer == answerOption.ASI_CRM_SG_Base_Currency__c) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('!='))
                    {
                        system.debug('curr2' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = (answer != answerOption.ASI_CRM_SG_Base_Currency__c) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('<'))
                    {
                        system.debug('curr3' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = ((answer < answerOption.ASI_CRM_SG_Base_Currency__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('>'))
                    {
                        system.debug('curr4' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = ((answer > answerOption.ASI_CRM_SG_Base_Currency__c) && ((iVar!=null && currentVar<iVar)||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('<='))
                    {
                        system.debug('curr5' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = ((answer <= answerOption.ASI_CRM_SG_Base_Currency__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
                    }
                    else if (condition.equalsIgnorecase('>='))
                    {
                        system.debug('curr6' + answer + ':' + answerOption.ASI_CRM_SG_Base_Currency__c);
                        bool = ((answer >= answerOption.ASI_CRM_SG_Base_Currency__c) && ((iVar!=null && (currentVar<iVar||currentVar==0))||(iVar==null))) ? true: false;
                    }
                    
                    //iVar = currentVar;
                    if(bool){
                        iVar = currentVar;
                        answerWeight = answerOption.ASI_CRM_SG_Weight__c * thresholdWeight;
                    }
                }
            }
            return answerWeight/100;
        }
        
        public final String LABEL = 'label';
        public final String FIELD = 'field';
                public List<String> getFieldSet(){
            List<String> fieldSet = new List<String>();
            
            fieldSet.add('ASI_CRM_SG_Condition__c');
            fieldSet.add('ASI_CRM_SG_Base_Currency__c');
            
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
    
    public class PicklistCriteria extends CriteriaFactoryBase implements ICriteriaInterface{
        public Component.Apex.OutputText criteriaStatement{set; get;}
        public Component.Apex.SelectList criteriaAnswer{set; get;}

        public boolean isRequired(){
            return true;
        }
        
        public void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions)
        {
            criteriaStatement = new Component.Apex.OutputText();
            criteriaStatement.value = criteriaInfo.ASI_CRM_SG_Question__c;
            
            criteriaAnswer = new Component.Apex.SelectList();
            criteriaAnswer.size = 1;
            criteriaAnswer.multiSelect = false;
            //List <SelectOption> radioGroup = new List<SelectOption>();
            //Component.Apex.SelectList picklist = new Component.Apex.SelectList();
            for (ASI_CRM_Criteria_Answer__c option: criteriaAnswerOptions){
                //radioOPtions.add(new SelectOption(option.ASI_CRM_SG_Label__c, option.ASI_CRM_SG_Answer__r.ASI_CRM_SG_Value__c));
                 Component.Apex.selectOption listOption = new Component.Apex.selectOption();
                 listOption.itemLabel = option.ASI_CRM_SG_Label__c;
                 listOption.itemValue = option.ASI_CRM_SG_Value__c;
                 listOption.itemDisabled = false;
                 criteriaAnswer.childComponents.add(listOption);
            }
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                //if (initValue != null || initValue.trim().length()>=0 || initValue != '')
                    //criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(Id accountId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                //if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    //criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.required = true;
                criteriaAnswer.styleClass = this.REQUIRED_STYLECLASS;
                //criteriaAnswer.label = ' ';
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                //itemGroup.childComponents.add(criteriaStatement);
                //itemGroup.childComponents.add(criteriaAnswer);
                
                Component.Apex.OutputPanel panel1 = new Component.Apex.OutputPanel();
                panel1.styleClass = 'requiredInput';
                panel1.layout= 'block';

                Component.Apex.OutputPanel panel2 = new Component.Apex.OutputPanel();
                panel2.styleClass = 'requiredBlock';
                panel2.layout = 'block';
                
                panel1.childComponents.add(panel2);
                panel1.childComponents.add(criteriaAnswer);
                
                
                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(panel1);
                
                
                return itemGroup;
        }
        
        public Double calculateCriteria(Double thresholdWeight, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, String answer)
        {
            System.debug('calculate4');
            Double answerWeight = 0;
            for (ASI_CRM_Criteria_Answer__c answerOption: criteriaAnswerOptions){
                answerOption.ASI_CRM_SG_Value__c = (answerOption.ASI_CRM_SG_Value__c!=null)?answerOption.ASI_CRM_SG_Value__c:'';
                if (answerOption.ASI_CRM_SG_Value__c.equalsIgnorecase(answer)){
                    answerWeight = answerOption.ASI_CRM_SG_Weight__c * thresholdWeight;
                }
            }
            return answerWeight/100;
        }
        
        public final String LABEL = 'label';
        public final String FIELD = 'field';
               public List<String> getFieldSet(){
            List<String> fieldSet = new List<String>();
            
            fieldSet.add('ASI_CRM_SG_Value__c');
            
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
    
     public class TextInputCriteria extends CriteriaFactoryBase implements ICriteriaInterface{
        public Component.Apex.OutputText criteriaStatement{set; get;}
        public Component.Apex.InputText criteriaAnswer{set; get;}
        
        public boolean isRequired(){
            return false;
        }
        
        public void setCriteria(ASI_CRM_Criteria_Threshold__c criteriaInfo, List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions)
        {
            criteriaStatement = new Component.Apex.OutputText();
            criteriaStatement.value = criteriaInfo.ASI_CRM_SG_Question__c;
            
            criteriaAnswer = new Component.Apex.InputText();
        }
            
        public Component.Apex.PageBlockSection getCriteriaComponent(ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.required = true;
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
        public Component.Apex.PageBlockSection getCriteriaComponent(Id accountId, ASI_CRM_Criteria_Threshold__c criteriaInfo, 
                                                                    List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
                                                                    String target, String initValue)
        {
                this.setCriteria(criteriaInfo, criteriaAnswerOptions);
                 if (initValue != null || initValue != '' || (initValue!=null && String.valueOf(initValue).trim().length()>=0))
                    criteriaAnswer.value = initValue;
                criteriaAnswer.expressions.value = target;
                //criteriaAnswer.label = ' ';
                //criteriaAnswer.required = true;
                
                Component.Apex.PageBlockSection itemGroup = new Component.Apex.PageBlockSection();

                itemGroup.childComponents.add(criteriaStatement);
                itemGroup.childComponents.add(criteriaAnswer);
                
                return itemGroup;
        }
        
        public Double calculateCriteria(Double thresholdWeight, 
                                List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions, 
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