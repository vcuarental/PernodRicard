<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CRA_REBAExpiringDay_AR</fullName>
        <description>CRA_REBAExpiringDay_AR</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CRA_RebaExpiringDay_AR</template>
    </alerts>
    <fieldUpdates>
        <fullName>CRA_UpdateCreditLimitGrante_AR</fullName>
        <field>Credit_line__c</field>
        <formula>CreditLimitGranted_ARG__c</formula>
        <name>CRA_UpdateCreditLimitGrante_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Account_ARG__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CRA_UpdateCreditline_AR</fullName>
        <description>Credit line field update. To &apos;1&apos;.</description>
        <field>Credit_line__c</field>
        <formula>1</formula>
        <name>CRA_UpdateCreditline_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Account_ARG__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CRA_UpdateIsREBAComplete_AR</fullName>
        <description>Update IsRebaComplete__c in account</description>
        <field>IsRebaComplete__c</field>
        <literalValue>1</literalValue>
        <name>CRA_UpdateIsREBAComplete_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Account_ARG__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CRA_ApprovalProcessAprovedUpdate</fullName>
        <description>Update Approval Process Aproved to true</description>
        <field>LAT_MX_ApprovalProcessAproved__c</field>
        <literalValue>1</literalValue>
        <name>LAT_MX_CRA_ApprovalProcessAprovedUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CRA_UpdatesApprovedByExecutive</fullName>
        <description>Updates the field Approved by Executive to true.</description>
        <field>LAT_MX_ApprovedByExecutive__c</field>
        <literalValue>1</literalValue>
        <name>LAT_MX_CRA_UpdatesApprovedByExecutive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CRA_UpdatesApprovedByManager</fullName>
        <description>Updates the field Approved by Manager to true.</description>
        <field>LAT_MX_ApprovedByManager__c</field>
        <literalValue>1</literalValue>
        <name>LAT_MX_CRA_UpdatesApprovedByManager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CRA_WF01_REBAexpiringDay_AR</fullName>
        <active>true</active>
        <description>REBA expiring day</description>
        <formula>($RecordType.DeveloperName=&apos;CRA_Standard_ARG&apos; || $RecordType.DeveloperName=&apos;CRA_Standard_UY&apos;) &amp;&amp; NOT( ISBLANK ( REBAExpDate_ARG__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CRA_REBAExpiringDay_AR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>CRA_REBAExpiringDay_AR</name>
                <type>Task</type>
            </actions>
            <offsetFromField>CRA_CredAnalysis_ARG__c.REBAExpDate_ARG__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CRA_WF01_UpdateCredit_line_ARG</fullName>
        <actions>
            <name>CRA_UpdateCreditline_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Credit line field update. To &apos;1&apos; for a child Account with type &apos;Sale_ARG&apos;.</description>
        <formula>NOT( ISBLANK( CreditLimitRequested_ARG__c ))   &amp;&amp;  ISBLANK (Account_ARG__r.ParentId )   &amp;&amp;  ISPICKVAL( Account_ARG__r.Type ,  &apos;Sale_ARG&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CRA_WF02_CredLimitGrantedValidation_AR</fullName>
        <actions>
            <name>CRA_UpdateCreditLimitGrante_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates limit credit of the account for a child Account with type &apos;Sale_ARG&apos;.</description>
        <formula>($RecordType.DeveloperName=&apos;CRA_Standard_ARG&apos; || $RecordType.DeveloperName=&apos;CRA_Standard_UY&apos;) &amp;&amp; ISBLANK(Account_ARG__r.ParentId) &amp;&amp; ISPICKVAL(Account_ARG__r.Type, &apos;Sale_ARG&apos;) &amp;&amp; ( NOT(ISBLANK(CreditLimitGranted_ARG__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CRA_WF04_UpdateIsREBAComplete_ARG</fullName>
        <actions>
            <name>CRA_UpdateIsREBAComplete_AR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update IsRebaComplete__c checkbox in account</description>
        <formula>($RecordType.DeveloperName=&apos;CRA_Standard_ARG&apos; || $RecordType.DeveloperName=&apos;CRA_Standard_UY&apos;) &amp;&amp; NOT(ISBLANK(REBA_ARG__c)) &amp;&amp; NOT(ISBLANK(REBAExpDate_ARG__c)) &amp;&amp; Account_ARG__r.Revenue_City__r.Descricao2__c = &apos;1-BUENOS AIRES&apos; &amp;&amp; NOT(ISBLANK(Account_ARG__r.ParentId))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>CRA_REBAExpiringDay_AR</fullName>
        <assignedTo>AR_Creditos_y_Cobranzas</assignedTo>
        <assignedToType>role</assignedToType>
        <dueDateOffset>-30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>CRA_CredAnalysis_ARG__c.REBAExpDate_ARG__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>CRA_REBAExpiringDay_AR</subject>
    </tasks>
</Workflow>
