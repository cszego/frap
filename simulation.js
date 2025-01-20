document.addEventListener("DOMContentLoaded", () => {
  const canvas = document.getElementById("simulationCanvas");
  const ctx = canvas.getContext("2d");

  const numLipids = 2000;
  const numSteps = 2000;
  const focalSize = 2;

  // Initialize lipids with random positions
  const lipids = Array.from({ length: numLipids }, () => ({
    pos: [Math.random() * 100, Math.random() * 100], // Random position within 100x100 canvas
    prevPos: [Math.random() * 100, Math.random() * 100],
    color: "blue",
  }));

  // Initialize focal particle
  let focal = {
    pos: [50, 50], // Starting in the middle
    prevPos: [50 + Math.random() * 0.1, 50 + Math.random() * 0.1],
    color: "red",
  };

  const forceCoefficient = 0.1;
  const frictionCoefficient = 0.1;

  function drawCircle(x, y, radius, color) {
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();
  }

  // Function to compute distance between two points
  function distance(p1, p2) {
    return Math.sqrt((p2[0] - p1[0]) ** 2 + (p2[1] - p1[1]) ** 2);
  }

  // Function to handle lipid interactions with focal point
  function updatePositions() {
    const interactionVectors = Array(numLipids).fill([0, 0]);
    const focalDirection = [
      focal.pos[0] - focal.prevPos[0],
      focal.pos[1] - focal.prevPos[1],
    ];

    lipids.forEach((lipid, index) => {
      // Update lipid position
      const dx = lipid.pos[0] - lipid.prevPos[0];
      const dy = lipid.pos[1] - lipid.prevPos[1];
      lipid.prevPos = [...lipid.pos];
      lipid.pos[0] += dx * 0.5 + (Math.random() - 0.5) / 3;
      lipid.pos[1] += dy * 0.5 + (Math.random() - 0.5) / 3;

      // Constrain lipid positions to the canvas
      lipid.pos[0] = Math.max(1, Math.min(100, lipid.pos[0]));
      lipid.pos[1] = Math.max(1, Math.min(100, lipid.pos[1]));

      // Check interactions with focal point
      const dist = distance(lipid.pos, focal.pos);
      if (dist <= focalSize + 1 && dist >= focalSize - 1) {
        // Interaction logic (force direction calculation)
        const lipidDirection = [
          lipid.pos[0] - lipid.prevPos[0],
          lipid.pos[1] - lipid.prevPos[1],
        ];
        const angle = Math.acos(
          (lipidDirection[0] * focalDirection[0] + lipidDirection[1] * focalDirection[1]) /
            (Math.sqrt(lipidDirection[0] ** 2 + lipidDirection[1] ** 2) * Math.sqrt(focalDirection[0] ** 2 + focalDirection[1] ** 2))
        );
        if (angle < Math.PI / 2) {
          lipid.color = "green"; // Lipid interacts with the focal point
          interactionVectors[index] = lipidDirection;
        } else {
          lipid.color = "blue"; // No interaction
        }
      }
    });

    // Calculate the force on the focal particle due to lipid interactions
    const force = interactionVectors.reduce((acc, vector) => {
      acc[0] += vector[0];
      acc[1] += vector[1];
      return acc;
    }, [0, 0]);

    // Move the focal point based on interactions and forces
    const focalDirectionNorm = Math.sqrt(focalDirection[0] ** 2 + focalDirection[1] ** 2);
    const normalizedDirection = [focalDirection[0] / focalDirectionNorm, focalDirection[1] / focalDirectionNorm];
    focal.pos[0] += forceCoefficient * force[0] + frictionCoefficient * normalizedDirection[0];
    focal.pos[1] += forceCoefficient * force[1] + frictionCoefficient * normalizedDirection[1];

    // Constrain focal particle to the canvas
    focal.pos[0] = Math.max(1, Math.min(100, focal.pos[0]));
    focal.pos[1] = Math.max(1, Math.min(100, focal.pos[1]));
  }

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Render lipids
    lipids.forEach((lipid) => {
      drawCircle(lipid.pos[0] * 8, lipid.pos[1] * 8, 5, lipid.color);
    });

    // Render focal particle
    drawCircle(focal.pos[0] * 8, focal.pos[1] * 8, focalSize * 8, focal.color);
  }

  function simulate() {
    updatePositions();
    render();
    requestAnimationFrame(simulate);
  }

  simulate();
});
