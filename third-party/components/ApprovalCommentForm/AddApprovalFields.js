/**
 * @flow
 * @file Add Approval Fields component for ApprovalComment component
 */

import * as React from 'react';
import { injectIntl, FormattedMessage } from 'react-intl';

import ContactDatalistItem from 'box-ui-elements/es/components/contact-datalist-item/ContactDatalistItem';
import DatePicker from 'box-ui-elements/es/components/date-picker/DatePicker';
import PillSelectorDropdown from 'box-ui-elements/es/components/pill-selector-dropdown/PillSelectorDropdown';

import messages from '../../messages';
import { ACTIVITY_TARGETS, INTERACTION_TARGET } from '../../interactionTargets';

type Props = {
    approvalDate?: Date,
    approverSelectorContacts?: SelectorItems<>,
    approverSelectorError: string,
    approvers: Array<any>,
    intl: any,
    onApprovalDateChange: Function,
    onApproverSelectorInput: Function,
    onApproverSelectorRemove: Function,
    onApproverSelectorSelect: Function,
};

const AddApprovalFields = ({
    approvalDate,
    approvers,
    approverSelectorContacts = [],
    approverSelectorError,
    onApprovalDateChange,
    onApproverSelectorInput,
    onApproverSelectorRemove,
    onApproverSelectorSelect,
    intl,
}: Props): React.Node => {
    const approverOptions: Array<any> = approverSelectorContacts
        // filter selected approvers
        .filter(({ id }) => !approvers.find(({ value }) => value === id))
        // map to datalist item format
        .map(({ id, item = {} }) => ({
            ...item,
            text: item.name,
            value: id,
        }));

    return (
        <div className="bcs-comment-add-approver-fields-container">
            <PillSelectorDropdown
                error={approverSelectorError}
                label={<FormattedMessage {...messages.approvalAssignees} />}
                onInput={onApproverSelectorInput}
                onRemove={onApproverSelectorRemove}
                onSelect={onApproverSelectorSelect}
                placeholder={intl.formatMessage(messages.approvalAddAssignee)}
                selectedOptions={approvers}
                selectorOptions={approverOptions}
            >
                {approverOptions.map(({ id, name, email }) => (
                    <ContactDatalistItem key={id} name={name} subtitle={email} />
                ))}
            </PillSelectorDropdown>
            <DatePicker
                className="bcs-comment-add-approver-date-input"
                inputProps={{
                    [INTERACTION_TARGET]: ACTIVITY_TARGETS.TASK_DATE_PICKER,
                }}
                label={<FormattedMessage {...messages.approvalDueDate} />}
                minDate={new Date()}
                name="approverDateInput"
                onChange={onApprovalDateChange}
                placeholder={intl.formatMessage(messages.approvalSelectDate)}
                value={approvalDate}
            />
        </div>
    );
};

export default injectIntl(AddApprovalFields);
