/**
 * @file CommentInlineError component used by Comment component.
 */

/* eslint-disable */
import * as React from 'react';

import InlineError from 'box-ui-elements/es/components/inline-error';
import PlainButton from 'box-ui-elements/es/components/plain-button';
import { FormattedMessage } from 'react-intl';

type Props = {
    action?: {
        onAction: Function,
        text: string
    },
    message: MessageDescriptor,
    title: MessageDescriptor
};

const CommentInlineError = ({ action, message, title }: Props): React.Node => (
    <InlineError className="bcs-comment-error" title={<FormattedMessage {...title} />}>
        <div>{<FormattedMessage {...message} />}</div>
        {action ? (
            <PlainButton className="lnk bcs-comment-error-action" onClick={action.onAction} type="button">
                {action.text}
            </PlainButton>
        ) : null}
    </InlineError>
);

export default CommentInlineError;
