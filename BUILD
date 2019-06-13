sh_binary(
    name = "sleep",
    srcs = [
        "sleep.sh",
    ],
    deps = [":sleeper"],
    data = glob(["foo/**", "bar/**", "baz/**"]),
)

sh_library(
    name = "sleeper",
    srcs = ["sleeper.sh"],
)
