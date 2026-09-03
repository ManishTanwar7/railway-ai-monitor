/**
 * Railway AI Monitoring - Glowing Train Light Cursor
 * Simulates a high-intensity railway locomotive headlight with dynamic beam direction
 */

document.addEventListener('DOMContentLoaded', () => {
  // Disable on mobile/touch devices
  if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
    return;
  }

  // Create cursor elements
  const cursor = document.createElement('div');
  cursor.id = 'train-light-cursor';
  cursor.innerHTML = `
    <div class="train-cursor-core">
      <div class="train-cursor-beam" id="cursor-beam"></div>
    </div>
  `;
  document.body.appendChild(cursor);

  // Trailing ghost light
  const trail = document.createElement('div');
  trail.className = 'train-cursor-trail';
  document.body.appendChild(trail);

  let mouseX = window.innerWidth / 2;
  let mouseY = window.innerHeight / 2;
  let cursorX = mouseX;
  let cursorY = mouseY;
  let trailX = mouseX;
  let trailY = mouseY;
  let prevX = mouseX;
  let prevY = mouseY;
  let targetAngle = -15;
  let currentAngle = -15;
  let isVisible = false;

  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
    
    if (!isVisible) {
      cursor.style.opacity = '1';
      trail.style.opacity = '0.6';
      isVisible = true;
    }

    // Calculate movement angle for directional headlight beam
    const dx = mouseX - prevX;
    const dy = mouseY - prevY;
    if (Math.abs(dx) > 1 || Math.abs(dy) > 1) {
      targetAngle = (Math.atan2(dy, dx) * 180 / Math.PI);
      prevX = mouseX;
      prevY = mouseY;
    }
  });

  window.addEventListener('mouseleave', () => {
    cursor.style.opacity = '0';
    trail.style.opacity = '0';
    isVisible = false;
  });

  // Smooth render loop
  const beam = document.getElementById('cursor-beam');
  
  function render() {
    // Lerp cursor position
    cursorX += (mouseX - cursorX) * 0.45;
    cursorY += (mouseY - cursorY) * 0.45;

    // Slower lerp for trailing particle
    trailX += (mouseX - trailX) * 0.15;
    trailY += (mouseY - trailY) * 0.15;

    // Angle interpolation for beam
    let angleDiff = targetAngle - currentAngle;
    // Normalize angle delta
    while (angleDiff < -180) angleDiff += 360;
    while (angleDiff > 180) angleDiff -= 360;
    currentAngle += angleDiff * 0.15;

    cursor.style.transform = `translate3d(${cursorX}px, ${cursorY}px, 0)`;
    trail.style.transform = `translate3d(${trailX - 3}px, ${trailY - 3}px, 0)`;
    
    if (beam) {
      beam.style.transform = `rotate(${currentAngle}deg)`;
    }

    requestAnimationFrame(render);
  }

  requestAnimationFrame(render);
});
