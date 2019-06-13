# Demo for managing processes when files change with Bazel

## Prequisites

* Install [Bazel](https://docs.bazel.build/versions/master/install.html)
* Install [bazel-watcher](https://github.com/bazelbuild/bazel-watcher#installation)

## Demo

`sleep.sh` is a shell script that spawns three processes that sleeps and blocks
for some time. It's declared as a `sh_binary` target in the BUILD file, which
depends on the `sleeper.sh` `sh_library` targets.

```
$ bazel run :sleep 
INFO: Analyzed target //:sleep (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //:sleep up-to-date:
  bazel-bin/sleep
INFO: Elapsed time: 0.081s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 1 total action
INFO: Build completed successfully, 1 total action
Parent process is 129480
129726 is going to sleep for 20 seconds
129727 is going to sleep for 30 seconds
129725 is going to sleep for 10 seconds
129725 has woken up
129726 has woken up
129727 has woken up
```

Note that `//:sleep` depends on a glob of all the files in `foo/`, `bar/` and
`baz/`. This is to tell Bazel that the `sleep.sh` executable depends on all of
the files in those directories, even though it doesn't actually use them for
this demo.

```python
sh_binary(
    name = "sleep",
    srcs = [
        "sleep.sh",
    ],
    deps = [":sleeper"],
    data = glob(["foo/**", "bar/**", "baz/**"]),
)
```

Now, if you run `//:sleep` again with the Bazel filesystem watcher, `ibazel`,
and make changes to files underneath those directories, `ibazel` will kill the
`sleep` process and all child processes, rebuild `//:sleep`, and re-run the
`sleep.sh` executable.

```
$ ibazel run :sleep 
State: QUERY
Querying for BUILD files...
Watching: 1 files
Querying for source files...
Watching: 5 files
State: RUN
Runing :sleep
INFO: Analyzed target //:sleep (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //:sleep up-to-date:
  bazel-bin/sleep
INFO: Elapsed time: 0.058s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 1 total action
Starting...State: WAIT
Parent process is 133543
133545 is going to sleep for 20 seconds
133544 is going to sleep for 10 seconds
133546 is going to sleep for 30 seconds

Detected source change. Rebuilding...
State: DEBOUNCE_RUN
133544 has woken up
State: RUN
Runing :sleep
INFO: Analyzed target //:sleep (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //:sleep up-to-date:
  bazel-bin/sleep
INFO: Elapsed time: 0.093s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 1 total action
Starting...State: WAIT
Parent process is 133876
133878 is going to sleep for 20 seconds
133879 is going to sleep for 30 seconds
133877 is going to sleep for 10 seconds

Detected source change. Rebuilding...
State: DEBOUNCE_RUN
State: RUN
Runing :sleep
INFO: Analyzed target //:sleep (0 packages loaded, 0 targets configured).
INFO: Found 1 target...
Target //:sleep up-to-date:
  bazel-bin/sleep
INFO: Elapsed time: 0.074s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 1 total action
Starting...State: WAIT
Parent process is 134165
134166 is going to sleep for 10 seconds
134167 is going to sleep for 20 seconds
134168 is going to sleep for 30 seconds
```

If you inspect the process tree on the system, notice that Bazel kills the
parent process and its subprocesses when `ibazel` detects a source change.
