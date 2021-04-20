<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_HK_PriceSet_Completed</fullName>
        <description>ASI_CRM_HK_PriceSet_Completed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ASI_HK_CRM_SYS_Supervisor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>pra.sfdcitsupport@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_HK_CRM_PAF/ASI_CRM_HK_PriceSet_Completed</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_TW_PAF_Final_to_Draft</fullName>
        <description>ASI CRM TW PAF (Final to Draft)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_TW_Email_Templates/ASI_CRM_TW_PAF_Final_to_Draft</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_Contract_Expiry_Alert_30_Days</fullName>
        <description>ASI HK CRM Contract Expiry Alert (30 Days)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert_30_D</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_Contract_Expiry_Alert_30_Days_Adjusted_Date</fullName>
        <description>ASI HK CRM Contract Expiry Alert (30 Days) Adjusted Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert_30_D</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_Contract_Expiry_Alert_7_Days</fullName>
        <description>ASI HK CRM Contract Expiry Alert (7 Days)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert_7_D</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_Contract_Expiry_Alert_7_Days_Adjusted_Date</fullName>
        <description>ASI HK CRM Contract Expiry Alert (7 Days) Adjusted Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert_7_D</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Approved</fullName>
        <description>ASI HK CRM PAF Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ASI_HK_CRM_Sales_Administration_Executive</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>jeanie.fung@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_PAF_Approved_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Contract_Expiry_Alert</fullName>
        <description>ASI HK CRM PAF Contract Expiry Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Contract_Expiry_Alert_Adjusted</fullName>
        <description>ASI HK CRM PAF Contract Expiry Alert-Adjusted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_Contract_Expiry_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Date_Adjustment_Approved</fullName>
        <description>ASI HK CRM PAF Date Adjustment Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_PAF_Date_Adjustment_Approved_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Date_Adjustment_Rejected</fullName>
        <description>ASI HK CRM PAF Date Adjustment Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_PAF_Date_Adjustment_Rejected_Alert</template>
    </alerts>
    <alerts>
        <fullName>ASI_HK_CRM_PAF_Rejected</fullName>
        <description>ASI HK CRM PAF Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_HK_CRM_PAF/ASI_HK_CRM_PAF_Rejected_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_Approved_Date</fullName>
        <field>ASI_CRM_Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>ASI CRM Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_HK_Deactivate_PAF</fullName>
        <field>ASI_CRM_HK_Active__c</field>
        <literalValue>0</literalValue>
        <name>ASI_CRM_HK_Deactivate_PAF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Change_RecordType_To_Editable</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_TW_Pre_Approval_Form</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM TW Change RecordType To Editable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Change_RecordType_to_ReadOnly</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_TW_Pre_Approval_Form_Read_only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM TW Change RecordType to ReadOnly</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Account_Channel</fullName>
        <field>ASI_CRM_Channel_Code__c</field>
        <formula>ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c</formula>
        <name>ASI CRM TW Copy Account Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_TW_Copy_Outlet_Region</fullName>
        <field>ASI_CRM_Outlet_Region__c</field>
        <formula>TEXT( ASI_CRM_Customer__r.ASI_CRM_Region__c )</formula>
        <name>ASI CRM TW Copy Outlet Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Approve_Final</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>Approve Final</literalValue>
        <name>ASI HK CRM Approve Final</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Clear_SD</fullName>
        <field>ASI_HK_CRM_SYS_Sales_Director_Approver__c</field>
        <name>ASI HK CRM Clear SD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Date_Adjustment_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_HK_Pre_Approval_Form_Date_Adjustment</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI HK CRM Date Adjustment Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_FD_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>FD Approved</literalValue>
        <name>ASI HK CRM FD Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_FD_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>FD Rejected</literalValue>
        <name>ASI HK CRM FD Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_FM_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>FM Approved</literalValue>
        <name>ASI HK CRM FM Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_FM_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>FM Rejected</literalValue>
        <name>ASI HK CRM FM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Final_Rejection</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>Reject Final</literalValue>
        <name>ASI HK CRM Final Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_HS_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>HS Approved</literalValue>
        <name>ASI HK CRM HS Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_HS_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>HS Rejected</literalValue>
        <name>ASI HK CRM HS Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_In_Progress</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI HK CRM In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Increment_the_Version_Number</fullName>
        <field>ASI_HK_CRM_PAF_Version_No__c</field>
        <formula>ASI_HK_CRM_PAF_Version_No__c + 1</formula>
        <name>ASI HK CRM Increment the Version Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_MD_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>MD Final</literalValue>
        <name>ASI HK CRM MD Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_MD_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>MD Rejected</literalValue>
        <name>ASI HK CRM MD Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_MKTD_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>MKTD Approved</literalValue>
        <name>ASI HK CRM MKTD Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_MKTD_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>MKTD Rejected</literalValue>
        <name>ASI HK CRM MKTD Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_MKTD_Rejected_t</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>MKTD Rejected</literalValue>
        <name>ASI HK CRM MKTD Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_PAF_to_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_HK_Pre_Approval_Form_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI HK CRM PAF to Read-Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_SA_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>SA Reviewed</literalValue>
        <name>ASI HK CRM SA Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_SA_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>SA Rejected</literalValue>
        <name>ASI HK CRM SA Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Set_PAF_FY_Value</fullName>
        <field>ASI_HK_CRM_SYS_Fiscal_Year__c</field>
        <formula>RIGHT(TEXT(IF(
AND(MONTH( DATEVALUE(CreatedDate) ) &gt;= 7, MONTH( DATEVALUE(CreatedDate) ) &lt;= 12), 
YEAR(DATEVALUE(CreatedDate)),
YEAR(DATEVALUE(CreatedDate))-1)),2)</formula>
        <name>ASI HK CRM Set PAF FY Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Supervisor_Approved</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>Supervisor Approved</literalValue>
        <name>ASI_HK_CRM_Supervisor_Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_HK_CRM_Supervisor_Rejected</fullName>
        <field>ASI_HK_CRM_PAF_Status__c</field>
        <literalValue>Supervisor Rejected</literalValue>
        <name>ASI HK CRM Supervisor Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM TW Change RecordType To Editable</fullName>
        <actions>
            <name>ASI_CRM_TW_Change_RecordType_To_Editable</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM TW Pre-Approval Form (Read-only)</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_Status__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <description>Change to normal editable if status is changed to &apos;Draft&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM TW Change RecordType To ReadOnly</fullName>
        <actions>
            <name>ASI_CRM_TW_Change_RecordType_to_ReadOnly</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM TW Pre-Approval Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_Status__c</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <description>Change to read-only if status is changed to &apos;Final&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM TW Copy Account Channel</fullName>
        <actions>
            <name>ASI_CRM_TW_Copy_Account_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM TW Pre-Approval Form (Read-only),ASI CRM TW Pre-Approval Form</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM TW Copy Outlet Region</fullName>
        <actions>
            <name>ASI_CRM_TW_Copy_Outlet_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI CRM TW Pre-Approval Form (Read-only),ASI CRM TW Pre-Approval Form</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM TW PAF %28Final to Draft%29</fullName>
        <actions>
            <name>ASI_CRM_TW_PAF_Final_to_Draft</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(     ISCHANGED(ASI_HK_CRM_PAF_Status__c),     TEXT(PRIORVALUE(ASI_HK_CRM_PAF_Status__c)) == &apos;Final&apos;,     TEXT(ASI_HK_CRM_PAF_Status__c) == &apos;Draft&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert %2830 Days%29 - Adjusted</fullName>
        <active>true</active>
        <formula>AND( OR( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FM Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FD Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;MD Final&quot;) ), NOT(ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c )),  NOT(ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c )) , OR( ASI_HK_CRM_Adjusted_End_Date__c &gt;= TODAY()+30, Temp_WF_Checking__c == TRUE) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_Contract_Expiry_Alert_30_Days_Adjusted_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_Adjusted_End_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert %2830 Days%29 - Not Adjusted</fullName>
        <active>true</active>
        <formula>AND( OR( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FM Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FD Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;MD Final&quot;) ), ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c ), ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c ), OR( ASI_HK_CRM_PAF_End_Date__c &gt; TODAY()+30, Temp_WF_Checking__c == TRUE)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_Contract_Expiry_Alert_30_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_End_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert %287 Days%29 - Adjusted</fullName>
        <active>true</active>
        <formula>AND(  OR( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FM Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FD Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;MD Final&quot;) ), NOT(ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c )),  NOT(ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c )) , OR( ASI_HK_CRM_Adjusted_End_Date__c &gt;= TODAY()+7, Temp_WF_Checking__c == TRUE)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_Contract_Expiry_Alert_7_Days_Adjusted_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_Adjusted_End_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert %287 Days%29 - Not Adjusted</fullName>
        <active>true</active>
        <formula>AND( OR( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FM Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;FD Approved&quot;), ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;MD Final&quot;) ), ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c ), ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c ), OR( ASI_HK_CRM_PAF_End_Date__c &gt; TODAY()+7, Temp_WF_Checking__c == TRUE)  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_Contract_Expiry_Alert_7_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_End_Date__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert - Adjusted</fullName>
        <active>true</active>
        <formula>AND( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot; ), NOT(ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c )), NOT(ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_PAF_Contract_Expiry_Alert_Adjusted</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_Adjusted_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Contract Expiry Alert - Not Adjusted</fullName>
        <active>true</active>
        <formula>AND( ISPICKVAL( ASI_HK_CRM_PAF_Status__c , &quot;Confirmed with Customer&quot; ), ISBLANK( ASI_HK_CRM_Adjusted_Start_Date__c ), ISBLANK( ASI_HK_CRM_Adjusted_End_Date__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ASI_HK_CRM_PAF_Contract_Expiry_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_End_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ASI HK CRM Remove SD Approver</fullName>
        <actions>
            <name>ASI_HK_CRM_Clear_SD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ASI_HK_CRM_SYS_Supervisor__c =  ASI_HK_CRM_SYS_Sales_Director_Approver__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI HK CRM Set PAF FY Number</fullName>
        <actions>
            <name>ASI_HK_CRM_Set_PAF_FY_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_HK_Deactivate_Past_BenchmarkPAF</fullName>
        <actions>
            <name>ASI_CRM_HK_Deactivate_PAF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_CRM_HK_Is_Benchmark__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_Adjusted_End_Date__c</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_CRM_HK_Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_HK_Price_Set_Completed</fullName>
        <actions>
            <name>ASI_CRM_HK_PriceSet_Completed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_HK_CRM_Pre_Approval_Form__c.ASI_CRM_Price_Set_Generation_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Email to owner and manager when price set was completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
