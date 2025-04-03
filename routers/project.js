const express = require('express');
const {createProject, updateProjectFiles, killProject} = require('../controllers/projectController');
const projectRouter = express.Router();

projectRouter.post('/setup-project', createProject);
projectRouter.put('/:projectName/files', updateProjectFiles);
projectRouter.delete('/:projectName', killProject);

module.exports = projectRouter;