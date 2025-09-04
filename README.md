# wallet
A short Clarity smart contract for fair and transparent Requests for Proposal (RFPs) on the Stacks blockchain. It uses commit–reveal bidding and on-chain winner recording to align with the vision of Google Clarity Web3.

✨ Key Features

🔒 Commit–Reveal Bidding – Vendors commit first, reveal later.

🕒 Deadline Control – Commit and reveal phases are enforced by block height.

🏆 Winner Finalization – Owner records the winner immutably.

📜 On-Chain Transparency – All actions stored permanently.

🚀 Lightweight Design – Under 70 lines, easy to audit and extend.

🔄 Workflow

Owner creates an RFP with deadlines.

Vendors commit hashed proposals.

Vendors reveal their proposals after commit phase.

Owner finalizes and records the winner.

📜 License

MIT – Free to use, adapt, and extend.
