document.addEventListener("DOMContentLoaded", () => {
  const canvas = document.getElementById("simulationCanvas");
  const ctx = canvas.getContext("2d");

  const numLipids = 2000;
  const numSteps = 2000;
  const focalSize = 2;

  const lipids = Array.from({ length: numLipids }, () => ({
    pos: [Math.random() * 100, Math.random() * 100],
    prevPos: [Math.random() * 100, Math.random() * 100],
    color: "blue",
  }));

  let focal = {
    pos: [50, 50],
    prevPos: [50 + Math.random() * 0.1, 50 + Math.random() * 0.1],
    color: "red",
  };

  function drawCircle(x, y, radius, color) {
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();
  }

  function updatePositions() {
    lipids.forEach((lipid) => {
      const dx = lipid.pos[0] - lipid.prevPos[0];
      const dy = lipid.pos[1] - lipid.prevPos[1];
      lipid.prevPos = [...lipid.pos];
      lipid.pos[0] += dx * 0.5 + (Math.random() - 0.5) / 3;
      lipid.pos[1] += dy * 0.5 + (Math.random() - 0.5) / 3;
      lipid.pos[0] = Math.max(1, Math.min(100, lipid.pos[0]));
      lipid.pos[1] = Math.max(1, Math.min(100, lipid.pos[1]));
    });

    const force = [0, 0];
    const direction = [
      focal.pos[0] - focal.prevPos[0],
      focal.pos[1] - focal.prevPos[1],
    ];
    const norm = Math.sqrt(direction[0] ** 2 + direction[1] ** 2);
    direction[0] /= norm;
    direction[1] /= norm;

    focal.prevPos = [...focal.pos];
    focal.pos[0] += 0.1 * force[0] + 0.7 * direction[0];
    focal.pos[1] += 0.1 * force[1] + 0.7 * direction[1];
  }

  function render() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    lipids.forEach((lipid) => {
      drawCircle(lipid.pos[0] * 8, lipid.pos[1] * 8, 5, lipid.color);
    });

    drawCircle(focal.pos[0] * 8, focal.pos[1] * 8, focalSize * 8, focal.color);
  }

  function simulate() {
    updatePositions();
    render();
    requestAnimationFrame(simulate);
  }

  simulate();
});
