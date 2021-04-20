<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EUR_CRM_Set_ExcludeContractActualAmt_Fal</fullName>
        <field>EUR_CRM_Excl_From_Contract_Act_Amt_ref__c</field>
        <literalValue>0</literalValue>
        <name>EUR_CRM_Set_ExcludeContractActualAmt_Fal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_ExcludeContractActualAmt_Tru</fullName>
        <description>Set Contract Activity Item - &apos;Exclude From Contract Actual Amount&apos; to true</description>
        <field>EUR_CRM_Excl_From_Contract_Act_Amt_ref__c</field>
        <literalValue>1</literalValue>
        <name>EUR_CRM_Set_ExcludeContractActualAmt_Tru</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Amount_Field</fullName>
        <field>EUR_CRM_Amount__c</field>
        <formula>EUR_CRM_Contract_Activity_Total__c</formula>
        <name>Update Amount Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_PT_Update_Is_Lumpsum_Field</fullName>
        <field>EUR_CRM_Is_Lumpsum__c</field>
        <literalValue>1</literalValue>
        <name>EUR PT Update Is Lumpsum Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_PT_Update_Is_Volume_Targets_Field</fullName>
        <description>Update  &apos;Is Volume Targets and Rebates&apos; checkbox field</description>
        <field>EUR_CRM_Is_Volume_Targets_and_Rebates__c</field>
        <literalValue>1</literalValue>
        <name>EUR PT Update Is Volume Targets Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_ZA_Update_Is_Event_Field</fullName>
        <description>This field update will set the &apos;Is Event&apos; field on the Contract Activity Item to True</description>
        <field>EUR_CRM_Is_Event__c</field>
        <literalValue>1</literalValue>
        <name>EUR ZA Update Is Event Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_ZA_Update_Is_POSM_Field</fullName>
        <field>EUR_CRM_Is_POS_Material__c</field>
        <literalValue>1</literalValue>
        <name>EUR ZA Update Is POSM Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_ZA_Update_Is_Trainings_Field</fullName>
        <field>EUR_CRM_Is_Trainings__c</field>
        <literalValue>1</literalValue>
        <name>EUR ZA Update Is Trainings Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_ZA_Update_Is_Uniforms_Field</fullName>
        <field>EUR_CRM_Is_Uniforms__c</field>
        <literalValue>1</literalValue>
        <name>EUR ZA Update Is Uniforms Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR PT - Update %27Is Lumpsum%27 Field</fullName>
        <actions>
            <name>EUR_PT_Update_Is_Lumpsum_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update &apos;Is Lumpsum&apos; Field for the Roll up summary field &apos;Lumpsum Total&apos; on the Contract</description>
        <formula>EUR_CRM_Mechanic_Type__r.Name = &quot;Lump Sum&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR PT - Update %27Is Volume Targets and Rebates%27 Field</fullName>
        <actions>
            <name>EUR_PT_Update_Is_Volume_Targets_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update &apos;Is Volume Targets and Rebates&apos; Field for the Roll up summary field &apos;Volume Targets and Rebates Total&apos; on the Contract</description>
        <formula>EUR_CRM_Mechanic_Type__r.Name = &quot;Volume Targets and Rebates&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA Update %27Is Event%27 field on Contract Activity Item</fullName>
        <actions>
            <name>EUR_ZA_Update_Is_Event_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule will mark the &apos;Is Event&apos; checkbox field on the Contract Activity Item to True if the Mechanic Type = &apos;Events&apos;</description>
        <formula>EUR_CRM_Mechanic_Type__r.Name = &apos;Events&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA Update %27Is POS Material%27 field</fullName>
        <actions>
            <name>EUR_ZA_Update_Is_POSM_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Mark &apos;Is POS Material&apos; field to True, if the Mechanic Type = &apos;POS material&apos;.</description>
        <formula>AND(EUR_CRM_Mechanic_Type__r.Name = &apos;POS material&apos;,EUR_CRM_Product_Items_Count__c &gt;= 1)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA Update %27Is Trainings%27 field</fullName>
        <actions>
            <name>EUR_ZA_Update_Is_Trainings_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Mark &apos;Is Trainings&apos; field to True , if the Mechanic Type = &apos;Trainings&apos;.</description>
        <formula>EUR_CRM_Mechanic_Type__r.Name = &apos;Trainings&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA Update %27Is Uniforms%27 field</fullName>
        <actions>
            <name>EUR_ZA_Update_Is_Uniforms_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Check the field  &apos;Is Uniforms&apos; on Contract Activity Item , if the Mechanic Type = &apos;Uniforms&apos;.</description>
        <formula>AND(EUR_CRM_Mechanic_Type__r.Name = &apos;Uniforms&apos;, EUR_CRM_Product_Items_Count__c &gt;= 1)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_FI_Update_Contract_Activity_Item_Exclude_Contract_Actual_Amt_To_False</fullName>
        <actions>
            <name>EUR_CRM_Set_ExcludeContractActualAmt_Fal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Contract Activity Item EUR_CRM_Excl_From_Contract_Act_Amt_ref__c field for Finland Contract to mechanic type EUR_CRM_Excl_From_Contract_Act_Amt__c value</description>
        <formula>EUR_CRM_Mechanic_Type__r.EUR_CRM_Exclude_From_Contract_Actual_Amt__c == false &amp;&amp;  (EUR_CRM_Contract__r.RecordType.DeveloperName == &apos;EUR_FI_Chain_Contract&apos; ||EUR_CRM_Contract__r.RecordType.DeveloperName == &apos;EUR_FI_Independent_Contract&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_FI_Update_Contract_Activity_Item_Exclude_Contract_Actual_Amt_To_True</fullName>
        <actions>
            <name>EUR_CRM_Set_ExcludeContractActualAmt_Tru</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Contract Activity Item EUR_CRM_Excl_From_Contract_Act_Amt_ref__c field for Finland Contract to mechanic type EUR_CRM_Exclude_From_Contract_Actual_Amt__c value</description>
        <formula>EUR_CRM_Mechanic_Type__r.EUR_CRM_Exclude_From_Contract_Actual_Amt__c == true &amp;&amp;  (EUR_CRM_Contract__r.RecordType.DeveloperName == &apos;EUR_FI_Chain_Contract&apos; ||EUR_CRM_Contract__r.RecordType.DeveloperName == &apos;EUR_FI_Independent_Contract&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
