<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EUR_BE_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <description>EUR BE Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_BE_Email_Templates/EUR_BE_Comp_Contract_Exp_Reminder</template>
    </alerts>
    <alerts>
        <fullName>EUR_BG_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <description>EUR BG Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_BG_Email_Templates/EUR_BG_Comp_Contract_Exp_Reminder</template>
    </alerts>
    <alerts>
        <fullName>EUR_DK_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <ccEmails>laura.ogor@laputatech.com</ccEmails>
        <ccEmails>verna.mugot@pernod-ricard.com</ccEmails>
        <description>EUR DK Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DK_Email_Templates/EUR_CRM_DK_Competitor_Contract_Expiration_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_DK_Send_Contract_Expiration_Reminder</fullName>
        <ccEmails>laura.ogor@laputatech.com</ccEmails>
        <ccEmails>verna.mugot@pernod-ricard.com</ccEmails>
        <description>EUR DK Send Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_DK_Email_Templates/EUR_CRM_DK_Contract_Expiration_Notification</template>
    </alerts>
    <alerts>
        <fullName>EUR_GB_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <description>EUR GB Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_GB_Email_Template/EUR_GB_Comp_Contract_Exp_Reminder</template>
    </alerts>
    <alerts>
        <fullName>EUR_MA_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <description>EUR MA Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_MA_Email_Templates/EUR_MA_Comp_Contract_Exp_Reminder</template>
    </alerts>
    <alerts>
        <fullName>EUR_NL_Send_Competitor_Contract_Expiration_Reminder</fullName>
        <description>EUR NL Send Competitor Contract Expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_NL_Email_Templates/EUR_NL_Comp_Contract_Exp_Reminder</template>
    </alerts>
    <alerts>
        <fullName>EUR_RU_Send_Competitor_Contract_Expiration_to_SR</fullName>
        <description>EUR RU Send Competitor Contract Expiration to SR</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_RU_Email_Templates/EUR_RU_Competitor_Contract_Expiry_Notification_to_SR</template>
    </alerts>
    <alerts>
        <fullName>EUR_SE_Send_Competitor_Contract_Expiration_Reminder_bis</fullName>
        <ccEmails>laura.ogor@laputatech.com</ccEmails>
        <description>EUR SE Send Competitor Contract Expiration Reminder bis</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EUR_CRM_SE_Email_Templates/EUR_CRM_SE_Competitor_Contract_Expiration_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>EUR_RU_Set_Active_to_False</fullName>
        <description>Set Active to False</description>
        <field>EUR_CRM_Active__c</field>
        <literalValue>0</literalValue>
        <name>EUR RU Set Active to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_Set_Contract_Tracker_to_Active</fullName>
        <field>EUR_CRM_Active__c</field>
        <literalValue>1</literalValue>
        <name>EUR Set Contract Tracker to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EUR_Set_Contract_Tracker_to_Inactive</fullName>
        <field>EUR_CRM_Active__c</field>
        <literalValue>0</literalValue>
        <name>EUR Set Contract Tracker to Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EUR Activate Contract Tracker %28EU%29</fullName>
        <actions>
            <name>EUR_Set_Contract_Tracker_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Contract Tracker (EU) Active Flag to True</description>
        <formula>EUR_CRM_Contract_End_Date__c  &gt;= TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR BE Competitor Contract is expiring in 4 months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BE Competitor Contract Tracker</value>
        </criteriaItems>
        <description>This is an email reminder sending to user when a Competitor Contract is being expired in 4 months.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_BE_Send_Competitor_Contract_Expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR BG Competitor Contract is expiring in THREE months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR BG Competitor Contract Tracker</value>
        </criteriaItems>
        <description>This is an email reminder sending to user when a Competitor Contract is being expired in THREE months.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_BG_Send_Competitor_Contract_Expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR DK Contract expiring in 3 months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR DK PR Contract Tracker</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_DK_Send_Contract_Expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR Deactivate Competitor Contract Tracking %28EU%29</fullName>
        <actions>
            <name>EUR_Set_Contract_Tracker_to_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>EUR_CRM_Contract_End_Date__c  &lt; TODAY() || EUR_CRM_Contract_End_Date__c  == NULL</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EUR GB Competitor Contract is expiring in 3 months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR GB Competitor Contract Tracker</value>
        </criteriaItems>
        <description>This is an email reminder sending to user when a Competitor Contract is being expired in 3 months.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_GB_Send_Competitor_Contract_Expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR MA Competitor Contract is expiring in TWO months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR MA Competitor Contract Tracker</value>
        </criteriaItems>
        <description>This is an email reminder sending to user when a Competitor Contract is being expired in TWO months.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_MA_Send_Competitor_Contract_Expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR RU Competitor Contract Expiry Notification to SR</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Competitor Contract Tracker</value>
        </criteriaItems>
        <description>Notify the SR that a Competitor Contract is about to expire.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_RU_Send_Competitor_Contract_Expiration_to_SR</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR RU Competitor Contract Inactivated ONE Month After Expiration</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR RU Competitor Contract Tracker</value>
        </criteriaItems>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.EUR_CRM_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Competitor Contract is Inactivated ONE Month After Expiration</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_RU_Set_Active_to_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EUR SE Competitor Contract expiring in 3 months</fullName>
        <active>true</active>
        <criteriaItems>
            <field>EUR_CRM_Contract_Tracker__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>EUR SE Competitor Contract Tracker</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EUR_SE_Send_Competitor_Contract_Expiration_Reminder_bis</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>EUR_CRM_Contract_Tracker__c.EUR_CRM_Contract_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
