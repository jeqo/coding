package org.example;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringJoiner;

class Command {
    final String name;
    final List<String> args;
    final boolean dots;

    public Command(String name, List<String> args, boolean dots) {
        this.name = name;
        this.args = args;
        this.dots = dots;
    }

    @Override
    public String toString() {
        return new StringJoiner(", ", Command.class.getSimpleName() + "[", "]")
                .add("name='" + name + "'")
                .add("args=" + args)
                .toString();
    }
}

class CommandLibrary {

    Map<List<String>, List<Command>> functions = new HashMap<>();
    void append(Set<Command> commands) {
        for (var comm : commands) {
            var funs = functions.getOrDefault(comm.args, new ArrayList<>());
            funs.add(comm);
            functions.put(comm.args, funs);
        }
    }

    List<Command> matches(List<String> args) {
        var match = new ArrayList<Command>();
        //requires dots?
        boolean req = false;
        String prev = null;
        for (var arg : args) {
            if (prev == null) {
                prev = arg;
            } else {
                if (prev.equals(arg)) {
                    req = true;
                } else {
                    prev = arg;
                    req = false;
                }
            }
        }
        if (req) {
            for (int i = 1; i <= args.size(); i++) {
                var key = args.subList(0, i);
                var c = functions.get(key);
                if (c != null) match.addAll(c);
            }
            for (var m : match) {
                if (m.args.size() != args.size()) {
                    if (m.dots) {
                        var additional = args.subList(m.args.size(), args.size());
                        var last = m.args.get(m.args.size() - 1);
                        for (var arg : additional) {
                            if (!last.equals(arg)) {
                                match.remove(m);
                                break;
                            }
                        }
                    } else {
                        match.remove(m);
                    }
                }
            }
            return match;
        } else {
            return functions.get(args);
        }
    }
}

public class Commands {

    public static void main(String[] args) {
        var lib = new CommandLibrary();
        lib.append(Set.of(
                new Command("funA", List.of("String", "Integer"), false),
                new Command("funB", List.of("Integer"), false),
                new Command("funC", List.of("Integer"), true)
        ));

        System.out.println(lib.matches(List.of("String", "Integer")));
        System.out.println(lib.matches(List.of("Integer")));
        System.out.println(lib.matches(List.of("Integer", "Integer")));
    }
}

