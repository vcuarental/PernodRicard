<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_RU_Notification_for_Rejection_to_SR</fullName>
        <description>EUR RU Notification for Rejection to SR</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_RU_Email_Templates/EUR_CRM_RU_Rejection_Notification_to_SR</template>
    </alerts>
    <fieldUpdates>
        <fullName>Country_South_Africa</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;South Africa&quot;</formula>
        <name>Country = South Africa</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_AT_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Austria&quot;</formula>
        <name>EUR AT Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_BE_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>IF(ISPICKVAL( EUR_CRM_Account_Country_Code__c, &quot;BE&quot;),
&quot;BELGIUM&quot;, &quot;LUXEMBURG&quot;)</formula>
        <name>EUR BE Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_BG_Update_SubChannel_Field_T</fullName>
        <description>This is a Workflow Field Update to get the value in Sub Channel Field to be pre-populated. 
If Record Type = Traditional Off Trade, Sub Channel = Traditional Off Trade</description>
        <field>EUR_CRM_Sub_Channel__c</field>
        <literalValue>Traditional Off-Trade</literalValue>
        <name>EUR BG Update SubChannel Field_T</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CCA_Update_Country</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>UPPER(TEXT(EUR_CRM_Account_Country_Code__c))</formula>
        <name>EUR CCA Update Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CH_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Switzerland&quot;</formula>
        <name>EUR CH Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_BG_Update_Country_Field</fullName>
        <description>This is a Workflow Field Update to get the value in Country Field to be pre-populated.</description>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Bulgaria&quot;</formula>
        <name>EUR BG Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_BG_Update_SubChannel_Field_M</fullName>
        <description>This is a Workflow Field Update to get the value in Sub Channel Field to be pre-populated.
If Record Type = Modern Off Trade, Sub Channel = Modern Off Trade</description>
        <field>EUR_CRM_Sub_Channel__c</field>
        <literalValue>Modern Off-Trade</literalValue>
        <name>EUR BG Update SubChannel Field_M</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Clear_Requested_Status_Field</fullName>
        <field>EUR_CRM_Status_Requested__c</field>
        <name>EUR CRM Clear Requested Status Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Clear_Specific_Reason_for_Deact</fullName>
        <field>EUR_CRM_Specific_Reason_for_Deactivation__c</field>
        <name>EUR CRM Clear Specific Reason for Deact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_DK_Update_Country_Field</fullName>
        <description>This is a workflow field update to get the value in country field to be pre-populated</description>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Denmark&quot;</formula>
        <name>EUR DK Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_EE_ChangeToDirOff</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_EE_DIR_OFF_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - EE - ChangeToDirOff</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_EE_ChangeToDirOffCPT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_EE_Direct_Off_Trade_w_CPT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - EE - ChangeToDirOffCPT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_FI_Set_Direct_Checkbox_field</fullName>
        <description>Sets the &apos;Direct&apos; field to TRUE if the record type is Direct</description>
        <field>EUR_JB_Direct__c</field>
        <literalValue>1</literalValue>
        <name>EUR CRM FI - Set Direct Checkbox field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_FI_Set_Indirect_Checkbox_field</fullName>
        <description>Sets the &apos;Indirect&apos; field to True if the Account (EU) recordtype is Indirect</description>
        <field>EUR_JB_Indirect__c</field>
        <literalValue>1</literalValue>
        <name>EUR CRM FI - Set Indirect Checkbox field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_LT_ChangeToDirOff</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_LT_DIR_OFF_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - LT - ChangeToDirOff</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_LT_ChangeToDirOffCPT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_LT_DIR_OFF_Trade_w_CPT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - LT - ChangeToDirOffCPT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_LV_ChangeToDirOff</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_LV_DIR_OFF_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - LV - ChangeToDirOff</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_LV_ChangeToDirOffCPT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>EUR_LV_DIR_OFF_Trade_w_CPT</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>EUR CRM - LV - ChangeToDirOffCPT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_NG_ON_Trade_Image_Level_Text</fullName>
        <description>Populate Image Level (Text) for NG On Trade Accounts</description>
        <field>EUR_CRM_Image_Level_Name_Text__c</field>
        <name>NG ON Trade Image Level Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_PT_Update_Country_Field</fullName>
        <description>This is a Workflow Field Update to get the value in Country Field to be pre-populated.</description>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Portugal&quot;</formula>
        <name>EUR PT Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Populate_ImageLevelNameText</fullName>
        <field>EUR_CRM_Image_Level_Name_Text__c</field>
        <formula>NULLVALUE(TEXT(EUR_CRM_Image_Level__r.EUR_CRM_Name__c), &quot;&quot;)</formula>
        <name>EUR_CRM_Populate_ImageLevelNameText</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Status_to_Active</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Active</literalValue>
        <name>EUR CRM Set Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Status_to_Inactive</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>EUR CRM Set Status to Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Status_to_New</fullName>
        <description>When Rejected by Sales Manager</description>
        <field>EUR_CRM_Status__c</field>
        <literalValue>New</literalValue>
        <name>EUR CRM Set Status to New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Set_Status_to_Prospect</fullName>
        <field>EUR_CRM_Status__c</field>
        <literalValue>Prospect</literalValue>
        <name>EUR CRM Set Status to Prospect</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Unlock</fullName>
        <field>EUR_CRM_Unlock__c</field>
        <literalValue>1</literalValue>
        <name>EUR_CRM_Unlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_CRM_Update_Account_Owner_Role</fullName>
        <field>EUR_CRM_Owner_Role_API_Name__c</field>
        <formula>Owner:User.UserRole.DeveloperName</formula>
        <name>EUR CRM Update Account Owner&apos;s Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DB_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Ireland&quot;</formula>
        <name>EUR DB Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DE_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Germany&quot;</formula>
        <name>EUR DE Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_DO_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Dominican Republic&quot;</formula>
        <name>EUR DO Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_FI_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Finland&quot;</formula>
        <name>EUR FI Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_GB_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;United Kingdom&quot;</formula>
        <name>EUR GB Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_IDL_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Ireland&quot;</formula>
        <name>EUR IDL Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_IT_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Italy&quot;</formula>
        <name>EUR IT Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_KE_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Kenya&quot;</formula>
        <name>EUR KE Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_MA_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Morocco&quot;</formula>
        <name>EUR MA Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_NG_Update_Country_Field</fullName>
        <description>This is a Workflow Field Update to get the value in Country Field to be pre-populated.</description>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Nigeria&quot;</formula>
        <name>EUR NG Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_NL_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Nederland&quot;</formula>
        <name>EUR NL Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_RU_Update_Country_Field</fullName>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Russia&quot;</formula>
        <name>EUR RU Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_SE_Update_Country_Field</fullName>
        <description>This is a workflow field update to get the value in country field to be pre-populated</description>
        <field>EUR_CRM_Country__c</field>
        <formula>&quot;Sweden&quot;</formula>
        <name>EUR SE Update Country Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR AT Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_AT_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR AT ON Gastronomy</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR AT ON Wholesaler</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR AT ON Hotel</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR AT ON System Gastronomy</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR AT ON Cash &amp; Carry</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BE Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_BE_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BE Wholesaler,EUR BE Off Trade,EUR BE B2B,EUR BE On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Account_Country_Code__c</field>
            <operation>equals</operation>
            <value>BE,LU</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BG Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_CRM_BG_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Modern Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Traditional Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Wholesaler</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Country Field for all BG Record Types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BG Pre-populate Sub-Channel for Modern Off Trade</fullName>
        <actions>
            <name>EUR_CRM_BG_Update_SubChannel_Field_M</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Modern Off Trade</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Sub Channel Field for all BG Off Trade Account.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BG Pre-populate Sub-Channel for Traditional Off Trade</fullName>
        <actions>
            <name>EUR_BG_Update_SubChannel_Field_T</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Traditional Off Trade</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Sub Channel Field for all BG Off Trade Account.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR CCA Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_CCA_Update_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CCA Off Trade,EUR CCA On Trade,EUR CCA Wholesaler</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Country__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR CH Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_CH_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CH ON HORECA</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CH ON Wholesaler</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CH ON Hotel</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CH ON Cash Carry</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR CH ON B2B</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - EE - Change Account Record Type to Off Trade</fullName>
        <actions>
            <name>EUR_CRM_EE_ChangeToDirOff</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EE Direct - Off Trade w/CPT</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade w/CPT to DIR OFF Trade when field EUR_CRM_Is_Tracking_Competitor_Promos__c is FALSE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - EE - Change Account Record Type to Off Trade CPT</fullName>
        <actions>
            <name>EUR_CRM_EE_ChangeToDirOffCPT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EE Direct - Off Trade</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade to DIR OFF Trade w/CPT when field EUR_CRM_Is_Tracking_Competitor_Promos__c is TRUE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - LT - Change Account Record Type to Off Trade</fullName>
        <actions>
            <name>EUR_CRM_LT_ChangeToDirOff</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LT Direct - Off Trade w/CPT</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade w/CPT to DIR OFF Trade when field EUR_CRM_Is_Tracking_Competitor_Promos__c is FALSE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - LT - Change Account Record Type to Off Trade CPT</fullName>
        <actions>
            <name>EUR_CRM_LT_ChangeToDirOffCPT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LT Direct - Off Trade</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade to DIR OFF Trade w/CPT when field EUR_CRM_Is_Tracking_Competitor_Promos__c is TRUE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - LV - Change Account Record Type to Off Trade</fullName>
        <actions>
            <name>EUR_CRM_LV_ChangeToDirOff</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LV Direct - Off Trade w/CPT</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade w/CPT to DIR OFF Trade when field EUR_CRM_Is_Tracking_Competitor_Promos__c is FALSE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM - LV - Change Account Record Type to Off Trade CPT</fullName>
        <actions>
            <name>EUR_CRM_LV_ChangeToDirOffCPT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LV Direct - Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Is_Tracking_Competitor_Promos__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Changes Account record type from DIR OFF Trade to DIR OFF Trade w/CPT when field EUR_CRM_Is_Tracking_Competitor_Promos__c is TRUE</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR CRM Set Account Owner%27s Role</fullName>
        <actions>
            <name>EUR_CRM_Update_Account_Owner_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Account owner has changed, set field Owner&apos;s Role with new Role</description>
        <formula>IF( ISBLANK(EUR_CRM_Owner_Role_API_Name__c), TRUE, IF( ISCHANGED(OwnerId), TRUE, FALSE ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR DB Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_DB_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DB On Trade Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DB Off Trade Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DB Wholesaler Account</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR DE Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_DE_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE Off Trade Retail</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE Off Trade New Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE On Trade Hotel</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE On Trade System Gastronomy</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE On Trade Special Stores</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE On Trade B2B</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DE On Trade New Business</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR DK Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_CRM_DK_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK OFF Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK Wholesaler</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Country Field for all DK Record Types</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR DO Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_DO_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DO On Trade,EUR DO Wholesaler,EUR DO Off Trade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR FI Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_FI_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Direct Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Direct On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Indirect Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Indirect On Trade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR GB Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_GB_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>GB FS Indirect</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR IDL Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_IDL_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IDL Off Trade Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IDL Wholesaler Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IDL On Trade Account</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR IT Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_IT_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IT On Trade Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IT Off Trade Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IT Wholesaler Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR IT Enoteca Account</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EUR KE Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_KE_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR KE Distributor,EUR KE Off Trade,EUR KE On Trade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR MA Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_MA_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR MA Distributor</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR MA Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR MA On Trade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR NG ON Trade Account</fullName>
        <actions>
            <name>EUR_CRM_NG_ON_Trade_Image_Level_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Image_Level_Name__c</field>
            <operation>equals</operation>
            <value>Iconic</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Image_Level_Name__c</field>
            <operation>equals</operation>
            <value>Premium</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Image_Level_Name__c</field>
            <operation>equals</operation>
            <value>Leading</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR NG Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_NG_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG Off Trade Modern</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG Off Trade Traditional</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NG Distributor</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Country Field for all NG Record Types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR NL Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_NL_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR NL On Trade Account,EUR NL Wholesaler,EUR NL Off Trade Account</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR PT Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_CRM_PT_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR PT On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR PT Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR PT Wholesaler</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR PT CandCs</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Country Field for all PT Record Types.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR RU Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_RU_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4 OR 5 OR 6</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Direct Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Direct Type 2 Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Distribution Center</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Distributor</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Indirect Off Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU On Trade</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR SE Pre-populate Country Field</fullName>
        <actions>
            <name>EUR_SE_Update_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR SE On Trade</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR SE Wholesaler</value>
        </criteriaItems>
        <description>This is a workflow rule to pre-populate the value in Country Field for all SE Record Types</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR ZA Pre-populate Country Field</fullName>
        <actions>
            <name>Country_South_Africa</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR ZA Distributor,EUR ZA Off Trade,EUR ZA On Trade Direct,EUR ZA On Trade Indirect</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Account__c.EUR_CRM_Country__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_FI_Set_Direct_field_on_Account_EU</fullName>
        <actions>
            <name>EUR_CRM_FI_Set_Direct_Checkbox_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Direct On Trade,EUR FI Direct Off Trade</value>
        </criteriaItems>
        <description>Set &apos;Direct&apos; field to TRUE on Account (EU) object if the record type is - EUR FI Direct On Trade or EUR FI Direct Off Trade</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EUR_CRM_FI_Set_Indirect_field_on_Account_EU</fullName>
        <actions>
            <name>EUR_CRM_FI_Set_Indirect_Checkbox_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Account__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR FI Indirect On Trade,EUR FI Indirect Off Trade</value>
        </criteriaItems>
        <description>Set &apos;Indirect&apos; field to TRUE on Account (EU) object if the record type is - EUR FI Indirect On Trade or EUR FI Indirect Off Trade</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
