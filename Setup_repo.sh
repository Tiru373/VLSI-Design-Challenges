#!/bin/bash
# setup_repo.sh – Create VLSI Design Challenges repo structure

# Root folders
mkdir -p VLSI-Design-Challenges/{challenges,scripts,assets}

# Challenge folders
mkdir -p VLSI-Design-Challenges/challenges/{01-FIFO-Design,02-Arbiter-Design}

# README.md
cat << 'EOF' > VLSI-Design-Challenges/README.md
# VLSI Design Challenges 🚀
A curated collection of VLSI Design Challenges with solutions, diagrams, scripts, and real-world case studies — to help freshers become industry-ready.
EOF

# LICENSE
cat << 'EOF' > VLSI-Design-Challenges/LICENSE
MIT License
EOF

# Example FIFO folder files
cat << 'EOF' > VLSI-Design-Challenges/challenges/01-FIFO-Design/README.md
# FIFO Design
Problem statement + solution + notes for interviews.
EOF

# Example Arbiter folder files
cat << 'EOF' > VLSI-Design-Challenges/challenges/02-Arbiter-Design/README.md
# Arbiter Design
Problem statement + solution + notes for interviews.
EOF

# Bash script template
cat << 'EOF' > VLSI-Design-Challenges/scripts/run_template.sh
#!/bin/bash
# Usage: ./run_template.sh <module_name>
# This is a generic run script placeholder.
echo "Compiling and simulating \$1..."
EOF
chmod +x VLSI-Design-Challenges/scripts/run_template.sh

# Repo banner placeholder
echo "Repo banner placeholder" > VLSI-Design-Challenges/assets/repo-banner.txt

echo "✅ Repo structure created successfully!"
