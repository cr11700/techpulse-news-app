import TurndownService, { Node as TurndownNode, Options, Rule } from 'turndown';

const highlightRegExp = /highlight-(?:text|source)-([a-z0-9]+)/;

function highlightedCodeBlock(turndownService: TurndownService) {
    turndownService.addRule('highlightedCodeBlock', {
        filter: function (node: TurndownNode) {
            const firstChild = (node as HTMLElement).firstChild as HTMLElement | null;
            return (
                node.nodeName === 'DIV' &&
                highlightRegExp.test((node as HTMLElement).className || '') &&
                firstChild != null &&
                firstChild.nodeName === 'PRE'
            );
        },
        replacement: function (content: string, node: TurndownNode, options: Options) {
            const className = ((node as HTMLElement).className || '');
            const language = (className.match(highlightRegExp) || [null, ''])[1];

            return (
                '\n\n' + options.fence + language + '\n' +
                ((node as HTMLElement).firstChild as HTMLElement)?.textContent +
                '\n' + options.fence + '\n\n'
            );
        }
    });
}

function strikethrough(turndownService: TurndownService) {
    turndownService.addRule('strikethrough', {
        filter: function (node: TurndownNode) {
            return (
                node.nodeName === 'del' ||
                node.nodeName === 's' ||
                node.nodeName === 'strike'
            );
        },
        replacement: function (content: string) {
            return '~' + content + '~';
        }
    });
}

const indexOf = Array.prototype.indexOf;
const every = Array.prototype.every;

type TableRule = Rule & {
    filter: ((node: TurndownNode) => boolean) | string | string[];
    replacement: (content: string, node: TurndownNode) => string;
};

const rules: Record<string, TableRule> = {};

rules.tableCell = {
    filter: ['th', 'td'],
    replacement: function (content: string, node: TurndownNode) {
        return cell(content, node);
    }
};

rules.tableRow = {
    filter: 'tr',
    replacement: function (content: string, node: TurndownNode) {
        let borderCells = '';
        const alignMap: Record<string, string> = { left: ':--', right: '--:', center: ':-:' };

        if (isHeadingRow(node as HTMLTableRowElement)) {
            for (let i = 0; i < (node as HTMLTableRowElement).childNodes.length; i++) {
                let border = '---';
                const align = (
                    ((node as HTMLTableRowElement).childNodes[i] as HTMLElement).getAttribute('align') || ''
                ).toLowerCase();

                if (align) border = alignMap[align] || border;

                borderCells += cell(border, (node as HTMLTableRowElement).childNodes[i] as TurndownNode);
            }
        }
        return '\n' + content + (borderCells ? '\n' + borderCells : '');
    }
};

rules.table = {
    filter: function (node: TurndownNode) {
        return node.nodeName === 'TABLE' && isHeadingRow((node as HTMLTableElement).rows[0]);
    },
    replacement: function (content: string) {
        // Ensure there are no blank lines
        content = content.replace('\n\n', '\n');
        return '\n\n' + content + '\n\n';
    }
};

rules.tableSection = {
    filter: ['thead', 'tbody', 'tfoot'],
    replacement: function (content: string) {
        return content;
    }
};

// A tr is a heading row if:
// - the parent is a THEAD
// - or if its the first child of the TABLE or the first TBODY (possibly
//   following a blank THEAD)
// - and every cell is a TH
function isHeadingRow(tr: any): boolean {
    const parentNode = tr.parentNode;
    return (
        parentNode.nodeName === 'THEAD' ||
        (
            parentNode.firstChild === tr &&
            (parentNode.nodeName === 'TABLE' || isFirstTbody(parentNode)) &&
            every.call(tr.childNodes, (n: any) => n.nodeName === 'TH')
        )
    );
}

function isFirstTbody(element: any): boolean {
    const previousSibling = element.previousSibling;
    return (
        element.nodeName === 'TBODY' && (
            !previousSibling ||
            (
                previousSibling.nodeName === 'THEAD' &&
                /^\s*$/i.test(previousSibling.textContent)
            )
        )
    );
}

function cell(content: string, node: TurndownNode): string {
    const index = indexOf.call((node.parentNode as Node).childNodes, node);
    let prefix = ' ';
    if (index === 0) prefix = '| ';
    return prefix + content + ' |';
}

function tables(turndownService: TurndownService) {
    turndownService.keep(function (node: TurndownNode) {
        return node.nodeName === 'TABLE' && !isHeadingRow((node as HTMLTableElement).rows[0]);
    });
    for (const key in rules) turndownService.addRule(key, rules[key]!);
}

function taskListItems(turndownService: TurndownService) {
    turndownService.addRule('taskListItems', {
        filter: function (node: any) {
            return node.type === 'checkbox' && node.parentNode.nodeName === 'LI';
        },
        replacement: function (content: string, node: any) {
            return (node.checked ? '[x]' : '[ ]') + ' ';
        }
    });
}

function gfm(turndownService: TurndownService) {
    turndownService.use([
        highlightedCodeBlock,
        strikethrough,
        tables,
        taskListItems
    ]);
}

export { gfm, highlightedCodeBlock, strikethrough, tables, taskListItems };
