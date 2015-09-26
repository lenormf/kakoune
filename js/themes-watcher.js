/*
 * themes-watcher.js for kakoune
 * by lenormf
 */

"use strict";

var CODE_EXAMPLE = {
    lang: "cpp",
    code: [
        "#include &lt;unistd.h&gt;",
        "#include \"assert.hh\"",
        "",
        "int register_env_vars()",
        "{",
        "    static const struct {",
        "        const char* name;",
        "        bool prefix;",
        "        String (*func)(StringView, const Context&);",
        "    } env_vars[] = { {",
        "            \"bufname\", false,",
        "            [](StringView name, const Context& context) -&gt; String",
        "            { return context.buffer().display_name(); }",
        "        },",
        "    };",
        "",
        "    ShellManager& shell_manager = ShellManager::instance();",
        "    for (auto& env_var : env_vars)",
        "        shell_manager.register_env_var(env_var.name, env_var.prefix, env_var.func);",
        "",
        "    return 0;",
        "}",
    ].join("\n"),
};

var forEachSelectorNode = function (node, selector, callback) {
    var nodes = node.querySelectorAll(selector);
    var nb_nodes = 0;

    if (nodes) {
        for (var n of nodes) {
            nb_nodes++;

            if (false === callback(n)) {
                break;
            }
        }
    }

    return nb_nodes;
}

var nodeAddClass = function (node, class_) {
    if (node.classList) {
        node.classList.add(class_);
    } else {
        node.className += " " + class_;
    }
}

forEachSelectorNode(document.querySelector("#list-themes"), "pre > code[theme]", function (code) {
    code.innerHTML = CODE_EXAMPLE.code;
    nodeAddClass(code, CODE_EXAMPLE.lang);

    hljs.configure({
        classPrefix: code.getAttribute("theme") + "-",
    });
    hljs.highlightBlock(code);
});
