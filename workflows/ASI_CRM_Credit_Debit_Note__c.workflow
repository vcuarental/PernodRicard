<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_SG_Create_FWO_Notification</fullName>
        <description>ASI_CRM_SG_Create_FWO_Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Note_FWO_Create_Notification</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_BR_Rejected_Email_Alert</fullName>
        <description>ASI CRM SG Credit/Debit BR Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_Rejected_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_BR_To_Finance_Verify</fullName>
        <description>ASI CRM SG Credit/Debit BR To Finance Verify</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Finance_Verify_Share</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_BR_To_Finance_Verify</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_CM_Rejected_Email_Alert</fullName>
        <description>ASI CRM SG Credit/Debit CM Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_Rejected_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_CM_To_Finance_Verify</fullName>
        <description>ASI CRM SG Credit/Debit CM To Finance Verify</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Finance_Verify_Share</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_CM_To_Finance_Verify</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_PP_Approved_Email_Alert</fullName>
        <description>ASI CRM SG Credit/Debit PP Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Prompt_Payment_Admin</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>ASI_CRM_SG_Prompt_Payment_Sales_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Credit_Debit_PP_Rejected_Email_Alert</fullName>
        <description>ASI CRM SG Credit/Debit PP Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ASI_CRM_SG_Prompt_Payment_Admin</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Credit_Debit_Rejected_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Manual_CNote_Approved_Email_Alert</fullName>
        <description>ASI CRM SG Manual CNote Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Manual_CNote_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Manual_CNote_JDE_Process_Alert</fullName>
        <description>ASI_CRM_SG_Manual_CNote_JDE_Process_Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>bengkiat.koh@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zaemah.zainal@pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Manual_CNote_JDE_Process_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Manual_CNote_Rejected_Email_Alert</fullName>
        <description>ASI CRM SG Manual CNote Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Manual_CNote_Rejected_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Wholesaler_CNote_Approved_Email_Alert</fullName>
        <description>ASI CRM SG Wholesaler CNote Approved Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Wholesaler_CNote_Approved_Email</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_SG_Wholesaler_CNote_Rejected_Email_Alert</fullName>
        <description>ASI CRM SG Wholesaler CNote Rejected Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_Wholesaler_CNote_Rejected_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Allow_To_Submit_False</fullName>
        <field>ASI_CRM_SYS_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM SG Allow To Submit False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_BR_Credit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Back_Rebate_Credit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG BR Credit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_CM_Credit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Contract_Margin_Credit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG CM Credit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_CM_Debit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Contract_Margin_Debit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG CM Debit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_GL_Date_Today</fullName>
        <field>ASI_CRM_GL_Date__c</field>
        <formula>Today()</formula>
        <name>ASI CRM SG GL Date Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Manual_CNote_Read_Only_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Manual_Credit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Manual CNote Read Only Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Manual_DNote_Read_Only_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Manual_Debit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Manual DNote Read Only Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_PP_Credit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Prompt_Payment_Credit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG PP Credit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_PP_Debit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Prompt_Payment_Debit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG PP Debit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Approved</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI CRM SG Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Draft</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI CRM SG Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Rejected</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI CRM SG Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Submitted</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI CRM SG Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Default_Currency_SG</fullName>
        <field>ASI_CRM_Currency__c</field>
        <literalValue>SGD</literalValue>
        <name>ASI CRM SG Update Default Currency SG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Default_Ex_Rate_to_1</fullName>
        <field>ASI_CRM_Exchange_Rate__c</field>
        <formula>1</formula>
        <name>ASI CRM SG Update Default Ex Rate to 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Month_From_FWO_Start</fullName>
        <field>ASI_CRM_Month__c</field>
        <formula>text( month( ASI_CRM_SG_FWO_Start_Date__c ))</formula>
        <name>ASI CRM SG Update Month From FWO Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Name_Credit</fullName>
        <field>Name</field>
        <formula>IF(month( ASI_CRM_SG_FWO_Start_Date__c ) &gt;=10,

&quot;WSCN - &quot;&amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp; text(month( ASI_CRM_SG_FWO_Start_Date__c )), &quot;Wholesaler Rebate - &quot;&amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp;&quot;0&quot;&amp; text(month( ASI_CRM_SG_FWO_Start_Date__c )))</formula>
        <name>ASI CRM SG Update Name Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Name_Debit</fullName>
        <field>Name</field>
        <formula>IF(month( ASI_CRM_SG_FWO_Start_Date__c ) &gt;=10,

&quot;WSDN - &quot;&amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp; text(month( ASI_CRM_SG_FWO_Start_Date__c )), &quot;WSDN - &quot;&amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp;&quot;0&quot;&amp; text(month( ASI_CRM_SG_FWO_Start_Date__c )))</formula>
        <name>ASI CRM SG Update Name Debit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Record_Type_to_Debit</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Wholesaler_Debit_Note</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Update Record Type to Debit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_WS_CN_Name</fullName>
        <field>Name</field>
        <formula>IF(month( ASI_CRM_SG_FWO_Start_Date__c ) &gt;=10, 
	&quot;Wholesaler Rebate - &quot;&amp; text( ASI_CRM_SG_Rebate_Type__c) &amp; &quot; - &quot; &amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp; text(month( ASI_CRM_SG_FWO_Start_Date__c )), 
	&quot;Wholesaler Rebate - &quot;&amp; text( ASI_CRM_SG_Rebate_Type__c) &amp; &quot; - &quot; &amp; text(Year( ASI_CRM_SG_FWO_Start_Date__c )) &amp; &quot;0&quot; &amp; text(month( ASI_CRM_SG_FWO_Start_Date__c ))
)</formula>
        <name>ASI CRM SG Update WS CN Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Update_Year_From_FWO_Start</fullName>
        <field>ASI_CRM_Year__c</field>
        <formula>text(year( ASI_CRM_SG_FWO_Start_Date__c ))</formula>
        <name>ASI CRM SG Update Year From FWO Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_WSBR_Credit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Back_Rebate_Credit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG WSBR Credit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_WSBR_Debit_Note_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Back_Rebate_Debit_Note_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG WSBR Debit Note Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_Update_Status_to_Submitted</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI CRM Update Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI CRM SG Update Month Year From FWO Start Date</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_Default_Currency_SG</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Default_Ex_Rate_to_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Month_From_FWO_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_CRM_SG_Update_Year_From_FWO_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Wholesaler FWO Period</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.ASI_CRM_SG_FWO_Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI CRM SG Update WS CN Name</fullName>
        <actions>
            <name>ASI_CRM_SG_Update_WS_CN_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Wholesaler Rebate Period</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_SG_FWO_Credit_Note_Notification</fullName>
        <actions>
            <name>ASI_CRM_SG_Create_FWO_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.ASI_CRM_SG_No_Of_Credit_Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Wholesaler Credit Note,SG Wholesaler Debit Note,SG Wholesaler Rebate Period</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASI_CRM_SG_ManualCNoteProcessedJDE</fullName>
        <actions>
            <name>ASI_CRM_SG_Manual_CNote_JDE_Process_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>SG Manual Debit Note Read Only,SG Manual Credit Note Read Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>ASI_CRM_Credit_Debit_Note__c.ASI_CRM_Document_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
