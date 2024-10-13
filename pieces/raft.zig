const std = @import("std");

// RPCs
const RequestVote = struct {};
const AppendEntries = struct {};

// State
const NodeState = enum {
    follower,
    candidate,
    leader,
};
const QuorumState = struct {
    term: usize,
    node_state: NodeState,
};
const NodeConfiguration = struct {
    // is there a better way to represent intervals in zig?
    election_timeout_interval_from: u64,
    election_timeout_interval_to: u63,
};

const Node = struct {
    node_config: NodeConfiguration,

    quorum_state: QuorumState,
};
